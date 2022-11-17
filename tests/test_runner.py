import unittest
import core_test
from checksumdir import dirhash
import test_checker

version = 3

class TestRunner(core_test.CoreTest):
    def test_it_does_nothing(self):
        self.copy_initial_state()
        running_script = 1
        try:
            for idx in range(1, version + 1):
                running_script = idx
                self.run_script(idx)
                state_01 = dirhash(f"state_expect_after/{idx}")
                after = dirhash(self.WORKING_DIR)
                self.assertEqual(state_01, after);

        except Exception as e:
            found_checker = True
            try:
                klass = getattr(test_checker, f"TestChecker{running_script}")
                some_object = klass()
                some_object.inspect()
                self.fail(f"\n{core_test.constants.RED}[TEST FAILED] (hash do not match, inspection found no errors):{core_test.constants.NC} {running_script}.py ({type(e)}: {e})")
            except AttributeError:
                found_checker = False

            if not found_checker:
                self.fail(f"\n{core_test.constants.RED}[TEST FAILED] (hash do not match):{core_test.constants.NC} {running_script}.py ({type(e)}: {e})")
        finally:
            self.cleanup()


if __name__ == '__main__':
    unittest.main()