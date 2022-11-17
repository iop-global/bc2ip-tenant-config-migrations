import unittest
import shutil
import os
import subprocess

class constants:
    RED='\033[1;31m'
    NC='\033[0m'

class CoreTest(unittest.TestCase):
    WORKING_DIR='working_state'
    REPO_NAME='bc2ip-tenant-config-migrations' # Note: this is the github repo's name.

    def run_script(self, idx: int):
        possibleAssetDir = f"../assets/{idx}"
        targetAssetDir = f"{self.WORKING_DIR}/{self.REPO_NAME}/assets/{idx}"
        if os.path.exists(possibleAssetDir):
            shutil.copytree(possibleAssetDir, targetAssetDir)

        subprocess.call(f"python3 ../scripts/{idx}.py {self.abs_working_dir()}", shell=True)

        if os.path.exists(possibleAssetDir):
            shutil.rmtree(f"{self.WORKING_DIR}/{self.REPO_NAME}")

    def abs_working_dir(self):
        return f"{os.getcwd()}/{self.WORKING_DIR}"

    def copy_initial_state(self):
        shutil.copytree('state_initial', self.WORKING_DIR)
        
    
    def cleanup(self):
        shutil.rmtree(self.WORKING_DIR)

    def fail_test(self, idx: int, reason: str):
        self.fail(f"[TEST FAILED] {idx}.py - REASON: {reason}")

    def handle_inspection_errors(self, idx: int, errors: list[str]):
        if len(errors) > 0:
            err_str = "\n-[INSPECTION ERR]: "
            err_str += "\n-[INSPECTION ERR]: ".join(errors)
            self.fail(f"\n{constants.RED}[TEST FAILED] {idx}.py - ERRORS: {err_str}{constants.NC}")