#===----------------------------------------------------------------------===##
#
# Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
#===----------------------------------------------------------------------===##

import os
import pickle
import pipes
import platform
import re
import tempfile

import libcxx.test.format
import lit
import lit.LitConfig
import lit.Test
import lit.TestRunner
import lit.util


def _memoizeExpensiveOperation(extractCacheKey):
  """
  Allows memoizing a very expensive operation.

  We pickle the cache key to make sure we store an immutable representation
  of it. If we stored an object and the object was referenced elsewhere, it
  could be changed from under our feet, which would break the cache.
  """
  def decorator(function):
    cache = {}
    def f(*args, **kwargs):
      cacheKey = pickle.dumps(extractCacheKey(*args, **kwargs))
      if cacheKey not in cache:
        cache[cacheKey] = function(*args, **kwargs)
      return cache[cacheKey]
    return f
  return decorator

def _executeScriptInternal(test, commands):
  """
  Returns (stdout, stderr, exitCode, timeoutInfo)

  TODO: This really should be easier to access from Lit itself
  """
  parsedCommands = libcxx.test.format.parseScript(test, preamble=commands)

  litConfig = lit.LitConfig.LitConfig(
    progname='lit',
    path=[],
    quiet=False,
    useValgrind=False,
    valgrindLeakCheck=False,
    valgrindArgs=[],
    noExecute=False,
    debug=False,
    isWindows=platform.system() == 'Windows',
    params={})
  _, tmpBase = libcxx.test.format._getTempPaths(test)
  execDir = os.path.dirname(test.getExecPath())
  for d in (execDir, os.path.dirname(tmpBase)):
    if not os.path.exists(d):
      os.makedirs(d)
  res = lit.TestRunner.executeScriptInternal(test, litConfig, tmpBase, parsedCommands, execDir)
  if isinstance(res, lit.Test.Result):
    res = ('', '', 127, None)
  return res

def _makeConfigTest(config, testPrefix=''):
  sourceRoot = os.path.join(config.test_exec_root, '__config_src__')
  execRoot = os.path.join(config.test_exec_root, '__config_exec__')
  suite = lit.Test.TestSuite('__config__', sourceRoot, execRoot, config)
  if not os.path.exists(sourceRoot):
    os.makedirs(sourceRoot)
  tmp = tempfile.NamedTemporaryFile(dir=sourceRoot, delete=False, suffix='.cpp',
                                    prefix=testPrefix)
  tmp.close()
  pathInSuite = [os.path.relpath(tmp.name, sourceRoot)]
  class TestWrapper(lit.Test.Test):
    def __enter__(self):       return self
    def __exit__(self, *args): os.remove(tmp.name)
  return TestWrapper(suite, pathInSuite, config)

@_memoizeExpensiveOperation(lambda c, s: (c.substitutions, c.environment, s))
def sourceBuilds(config, source):
  """
  Return whether the program in the given string builds successfully.

  This is done by compiling and linking a program that consists of the given
  source with the %{cxx} substitution, and seeing whether that succeeds.
  """
  with _makeConfigTest(config) as test:
    with open(test.getSourcePath(), 'w') as sourceFile:
      sourceFile.write(source)
    out, err, exitCode, timeoutInfo = _executeScriptInternal(test, [
      "%{cxx} %s %{flags} %{compile_flags} %{link_flags} -o %t.exe"
    ])
    _executeScriptInternal(test, ['rm %t.exe'])
    return exitCode == 0

@_memoizeExpensiveOperation(lambda c, p, args=None, testPrefix='': (c.substitutions, c.environment, p, args))
def programOutput(config, program, args=None, testPrefix=''):
  """
  Compiles a program for the test target, run it on the test target and return
  the output.

  If the program fails to compile or run, None is returned instead. Note that
  execution of the program is done through the %{exec} substitution, which means
  that the program may be run on a remote host depending on what %{exec} does.
  """
  if args is None:
    args = []
  with _makeConfigTest(config, testPrefix=testPrefix) as test:
    with open(test.getSourcePath(), 'w') as source:
      source.write(program)
    try:
      _, _, exitCode, _ = _executeScriptInternal(test, [
        "%{cxx} %s %{flags} %{compile_flags} %{link_flags} -o %t.exe",
      ])
      if exitCode != 0:
        return None

      out, err, exitCode, _ = _executeScriptInternal(test, [
        "%{{exec}} %t.exe {}".format(' '.join(args))
      ])
      if exitCode != 0:
        return None

      actualOut = re.search("command output:\n(.+)\n$", out, flags=re.DOTALL)
      actualOut = actualOut.group(1) if actualOut else ""
      return actualOut

    finally:
      _executeScriptInternal(test, ['rm %t.exe'])

@_memoizeExpensiveOperation(lambda c, f: (c.substitutions, c.environment, f))
def hasCompileFlag(config, flag):
  """
  Return whether the compiler in the configuration supports a given compiler flag.

  This is done by executing the %{cxx} substitution with the given flag and
  checking whether that succeeds.
  """
  with _makeConfigTest(config) as test:
    out, err, exitCode, timeoutInfo = _executeScriptInternal(test, [
      "%{{cxx}} -xc++ {} -Werror -fsyntax-only %{{flags}} %{{compile_flags}} {}".format(os.devnull, flag)
    ])
    return exitCode == 0

@_memoizeExpensiveOperation(lambda c, l: (c.substitutions, c.environment, l))
def hasAnyLocale(config, locales):
  """
  Return whether the runtime execution environment supports a given locale.
  Different systems may use different names for a locale, so this function checks
  whether any of the passed locale names is supported by setlocale() and returns
  true if one of them works.

  This is done by executing a program that tries to set the given locale using
  %{exec} -- this means that the command may be executed on a remote host
  depending on the %{exec} substitution.
  """
  # Avoid the (potentially) slow checks for locale support if the library
  # under test doesn't care about localizatin (e.g. libunwind). This can speed
  # up the test suite significantly when running it on an emulator over SSH.
  if not getattr(config, "test_localization", True):
    return False
  program = """
    #include <locale.h>
    #include <stdio.h>
    int main(int argc, char** argv) {
      // For debugging purposes print which locales are (not) supported.
      for (int i = 1; i < argc; i++) {
        if (::newlocale(LC_ALL_MASK, argv[1], 0) != NULL &&
            ::setlocale(LC_ALL, argv[i]) != NULL) {
          printf("%s is supported.\\n", argv[i]);
          return 0;
        }
        printf("%s is not supported.\\n", argv[i]);
      }
      return 1;
    }
  """
  return programOutput(config, program, args=[pipes.quote(l) for l in locales],
                       testPrefix="check_locale_" + locales[0]) is not None

def hasNewLocale(config):
  """
  Return whether the runtime execution environment supports newlocale.
  Some C libraries (e.g. some verision of newlib) don't.
  """
  program = """
    #include <locale.h>
    int main() {
      if (::newlocale(LC_ALL_MASK, "C", 0) != NULL) return 0;
      return 1;
    }
  """
  return programOutput(config, program) != None


@_memoizeExpensiveOperation(lambda c, flags='': (c.substitutions, c.environment, flags))
def compilerMacros(config, flags=''):
  """
  Return a dictionary of predefined compiler macros.

  The keys are strings representing macros, and the values are strings
  representing what each macro is defined to.

  If the optional `flags` argument (a string) is provided, these flags will
  be added to the compiler invocation when generating the macros.
  """
  with _makeConfigTest(config) as test:
    with open(test.getSourcePath(), 'w') as sourceFile:
      # Make sure files like <__config> are included, since they can define
      # additional macros.
      sourceFile.write("#include <cstddef>")
    unparsedOutput, err, exitCode, timeoutInfo = _executeScriptInternal(test, [
      "%{{cxx}} %s -dM -E %{{flags}} %{{compile_flags}} {}".format(flags)
    ])
    parsedMacros = dict()
    defines = (l.strip() for l in unparsedOutput.split('\n') if l.startswith('#define '))
    for line in defines:
      line = line[len('#define '):]
      macro, _, value = line.partition(' ')
      parsedMacros[macro] = value
    return parsedMacros

def featureTestMacros(config, flags=''):
  """
  Return a dictionary of feature test macros.

  The keys are strings representing feature test macros, and the values are
  integers representing the value of the macro.
  """
  allMacros = compilerMacros(config, flags)
  return {m: int(v.rstrip('LlUu')) for (m, v) in allMacros.items() if m.startswith('__cpp_')}


def _addToSubstitution(substitutions, key, value):
  return [(k, v + ' ' + value) if k == key else (k, v) for (k, v) in substitutions]


class ConfigAction(object):
  """
  This class represents an action that can be performed on a Lit TestingConfig
  object.

  Examples of such actions are adding or modifying substitutions, Lit features,
  etc. This class only provides the interface of such actions, and it is meant
  to be subclassed appropriately to create new actions.
  """
  def applyTo(self, config):
    """
    Applies the action to the given configuration.

    This should modify the configuration object in place, and return nothing.

    If applying the action to the configuration would yield an invalid
    configuration, and it is possible to diagnose it here, this method
    should produce an error. For example, it should be an error to modify
    a substitution in a way that we know for sure is invalid (e.g. adding
    a compiler flag when we know the compiler doesn't support it). Failure
    to do so early may lead to difficult-to-diagnose issues down the road.
    """
    pass

  def pretty(self, config, litParams):
    """
    Returns a short and human-readable string describing what this action does.

    This is used for logging purposes when running the test suite, so it should
    be kept concise.
    """
    pass


class AddFeature(ConfigAction):
  """
  This action defines the given Lit feature when running the test suite.

  The name of the feature can be a string or a callable, in which case it is
  called with the configuration to produce the feature name (as a string).
  """
  def __init__(self, name):
    self._name = name

  def _getName(self, config):
    name = self._name(config) if callable(self._name) else self._name
    if not isinstance(name, str):
      raise ValueError("Lit feature did not resolve to a string (got {})".format(name))
    return name

  def applyTo(self, config):
    config.available_features.add(self._getName(config))

  def pretty(self, config, litParams):
    return 'add Lit feature {}'.format(self._getName(config))


class AddFlag(ConfigAction):
  """
  This action adds the given flag to the %{flags} substitution.

  The flag can be a string or a callable, in which case it is called with the
  configuration to produce the actual flag (as a string).
  """
  def __init__(self, flag):
    self._getFlag = lambda config: flag(config) if callable(flag) else flag

  def applyTo(self, config):
    flag = self._getFlag(config)
    assert hasCompileFlag(config, flag), "Trying to enable flag {}, which is not supported".format(flag)
    config.substitutions = _addToSubstitution(config.substitutions, '%{flags}', flag)

  def pretty(self, config, litParams):
    return 'add {} to %{{flags}}'.format(self._getFlag(config))


class AddCompileFlag(ConfigAction):
  """
  This action adds the given flag to the %{compile_flags} substitution.

  The flag can be a string or a callable, in which case it is called with the
  configuration to produce the actual flag (as a string).
  """
  def __init__(self, flag):
    self._getFlag = lambda config: flag(config) if callable(flag) else flag

  def applyTo(self, config):
    flag = self._getFlag(config)
    assert hasCompileFlag(config, flag), "Trying to enable compile flag {}, which is not supported".format(flag)
    config.substitutions = _addToSubstitution(config.substitutions, '%{compile_flags}', flag)

  def pretty(self, config, litParams):
    return 'add {} to %{{compile_flags}}'.format(self._getFlag(config))


class AddLinkFlag(ConfigAction):
  """
  This action adds the given flag to the %{link_flags} substitution.

  The flag can be a string or a callable, in which case it is called with the
  configuration to produce the actual flag (as a string).
  """
  def __init__(self, flag):
    self._getFlag = lambda config: flag(config) if callable(flag) else flag

  def applyTo(self, config):
    flag = self._getFlag(config)
    assert hasCompileFlag(config, flag), "Trying to enable link flag {}, which is not supported".format(flag)
    config.substitutions = _addToSubstitution(config.substitutions, '%{link_flags}', flag)

  def pretty(self, config, litParams):
    return 'add {} to %{{link_flags}}'.format(self._getFlag(config))


class AddOptionalWarningFlag(ConfigAction):
  """
  This action adds the given warning flag to the %{compile_flags} substitution,
  if it is supported by the compiler.

  The flag can be a string or a callable, in which case it is called with the
  configuration to produce the actual flag (as a string).
  """
  def __init__(self, flag):
    self._getFlag = lambda config: flag(config) if callable(flag) else flag

  def applyTo(self, config):
    flag = self._getFlag(config)
    # Use -Werror to make sure we see an error about the flag being unsupported.
    if hasCompileFlag(config, '-Werror ' + flag):
      config.substitutions = _addToSubstitution(config.substitutions, '%{compile_flags}', flag)

  def pretty(self, config, litParams):
    return 'add {} to %{{compile_flags}}'.format(self._getFlag(config))


class Feature(object):
  """
  Represents a Lit available feature that is enabled whenever it is supported.

  A feature like this informs the test suite about a capability of the compiler,
  platform, etc. Unlike Parameters, it does not make sense to explicitly
  control whether a Feature is enabled -- it should be enabled whenever it
  is supported.
  """
  def __init__(self, name, actions=None, when=lambda _: True):
    """
    Create a Lit feature for consumption by a test suite.

    - name
        The name of the feature. This is what will end up in Lit's available
        features if the feature is enabled. This can be either a string or a
        callable, in which case it is passed the TestingConfig and should
        generate a string representing the name of the feature.

    - actions
        An optional list of ConfigActions to apply when the feature is supported.
        An AddFeature action is always created regardless of any actions supplied
        here -- these actions are meant to perform more than setting a corresponding
        Lit feature (e.g. adding compiler flags). If 'actions' is a callable, it
        is called with the current configuration object to generate the actual
        list of actions.

    - when
        A callable that gets passed a TestingConfig and should return a
        boolean representing whether the feature is supported in that
        configuration. For example, this can use `hasCompileFlag` to
        check whether the compiler supports the flag that the feature
        represents. If omitted, the feature will always be considered
        supported.
    """
    self._name = name
    self._actions = [] if actions is None else actions
    self._isSupported = when

  def _getName(self, config):
    name = self._name(config) if callable(self._name) else self._name
    if not isinstance(name, str):
      raise ValueError("Feature did not resolve to a name that's a string, got {}".format(name))
    return name

  def getActions(self, config):
    """
    Return the list of actions associated to this feature.

    If the feature is not supported, an empty list is returned.
    If the feature is supported, an `AddFeature` action is automatically added
    to the returned list of actions, in addition to any actions provided on
    construction.
    """
    if not self._isSupported(config):
      return []
    else:
      actions = self._actions(config) if callable(self._actions) else self._actions
      return [AddFeature(self._getName(config))] + actions

  def pretty(self, config):
    """
    Returns the Feature's name.
    """
    return self._getName(config)


def _str_to_bool(s):
  """
  Convert a string value to a boolean.

  True values are "y", "yes", "t", "true", "on" and "1", regardless of capitalization.
  False values are "n", "no", "f", "false", "off" and "0", regardless of capitalization.
  """
  trueVals = ["y", "yes", "t", "true", "on", "1"]
  falseVals = ["n", "no", "f", "false", "off", "0"]
  lower = s.lower()
  if lower in trueVals:
    return True
  elif lower in falseVals:
    return False
  else:
    raise ValueError("Got string '{}', which isn't a valid boolean".format(s))


class Parameter(object):
  """
  Represents a parameter of a Lit test suite.

  Parameters are used to customize the behavior of test suites in a user
  controllable way. There are two ways of setting the value of a Parameter.
  The first one is to pass `--param <KEY>=<VALUE>` when running Lit (or
  equivalenlty to set `litConfig.params[KEY] = VALUE` somewhere in the
  Lit configuration files. This method will set the parameter globally for
  all test suites being run.

  The second method is to set `config.KEY = VALUE` somewhere in the Lit
  configuration files, which sets the parameter only for the test suite(s)
  that use that `config` object.

  Parameters can have multiple possible values, and they can have a default
  value when left unspecified. They can also have any number of ConfigActions
  associated to them, in which case the actions will be performed on the
  TestingConfig if the parameter is enabled. Depending on the actions
  associated to a Parameter, it may be an error to enable the Parameter
  if some actions are not supported in the given configuration. For example,
  trying to set the compilation standard to C++23 when `-std=c++23` is not
  supported by the compiler would be an error.

  One important point is that Parameters customize the behavior of the test
  suite in a bounded way, i.e. there should be a finite set of possible choices
  for `<VALUE>`. While this may appear to be an aggressive restriction, this
  is actually a very important constraint that ensures that the set of
  configurations supported by a test suite is finite. Otherwise, a test
  suite could have an unbounded number of supported configurations, and
  nobody wants to be stuck maintaining that. If it's not possible for an
  option to have a finite set of possible values (e.g. the path to the
  compiler), it can be handled in the `lit.cfg`, but it shouldn't be
  represented with a Parameter.
  """
  def __init__(self, name, choices, type, help, actions, default=None):
    """
    Create a Lit parameter to customize the behavior of a test suite.

    - name
        The name of the parameter that can be used to set it on the command-line.
        On the command-line, the parameter can be set using `--param <name>=<value>`
        when running Lit. This must be non-empty.

    - choices
        A non-empty set of possible values for this parameter. This must be
        anything that can be iterated. It is an error if the parameter is
        given a value that is not in that set, whether explicitly or through
        a default value.

    - type
        A callable that can be used to parse the value of the parameter given
        on the command-line. As a special case, using the type `bool` also
        allows parsing strings with boolean-like contents.

    - help
        A string explaining the parameter, for documentation purposes.
        TODO: We should be able to surface those from the Lit command-line.

    - actions
        A callable that gets passed the parsed value of the parameter (either
        the one passed on the command-line or the default one), and that returns
        a list of ConfigAction to perform given the value of the parameter.
        All the ConfigAction must be supported in the given configuration.

    - default
        An optional default value to use for the parameter when no value is
        provided on the command-line. If the default value is a callable, it
        is called with the TestingConfig and should return the default value
        for the parameter. Whether the default value is computed or specified
        directly, it must be in the 'choices' provided for that Parameter.
    """
    self._name = name
    if len(self._name) == 0:
      raise ValueError("Parameter name must not be the empty string")

    self._choices = list(choices) # should be finite
    if len(self._choices) == 0:
      raise ValueError("Parameter '{}' must be given at least one possible value".format(self._name))

    self._parse = lambda x: (_str_to_bool(x) if type is bool and isinstance(x, str)
                                             else type(x))
    self._help = help
    self._actions = actions
    self._default = default

  def _getValue(self, config, litParams):
    """
    Return the value of the parameter given the configuration objects.
    """
    param = getattr(config, self.name, None)
    param = litParams.get(self.name, param)
    if param is None and self._default is None:
      raise ValueError("Parameter {} doesn't have a default value, but it was not specified in the Lit parameters or in the Lit config".format(self.name))
    getDefault = lambda: self._default(config) if callable(self._default) else self._default
    value = self._parse(param) if param is not None else getDefault()
    if value not in self._choices:
      raise ValueError("Got value '{}' for parameter '{}', which is not in the provided set of possible choices: {}".format(value, self.name, self._choices))
    return value

  @property
  def name(self):
    """
    Return the name of the parameter.

    This is the name that can be used to set the parameter on the command-line
    when running Lit.
    """
    return self._name

  def getActions(self, config, litParams):
    """
    Return the list of actions associated to this value of the parameter.
    """
    return self._actions(self._getValue(config, litParams))

  def pretty(self, config, litParams):
    """
    Return a pretty representation of the parameter's name and value.
    """
    return "{}={}".format(self.name, self._getValue(config, litParams))
