function test_suite = test_of_abs
try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions=localfunctions();
catch % no problem; early Matlab versions can use initTestSuite fine
end
initTestSuite;
end

function test_abs_scalar
assertTrue(abs(-1)==1)
assertEqual(abs(-NaN),NaN);
assertEqual(abs(-Inf),Inf);
assertEqual(abs(0),0)
assertElementsAlmostEqual(abs(-1e-13),0)
end

function test_abs_vector
assertEqual(abs([-1 1 -3]),[1 1 3]);
end

function test_abs_exceptions
% GNU Octave and Matlab use different error identifiers
if moxunit_util_platform_is_octave()
    assertExceptionThrown(@()abs(struct),'');
else
    assertExceptionThrown(@()abs(struct),...
        'MATLAB:UndefinedFunction');
end
end

function test_skipping
    moxunit_throw_test_skipped_exception('Pumpkins!')
end

%
function test_failure
    assertFalse(true)
end
%}