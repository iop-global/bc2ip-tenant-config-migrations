import core_test
import os

class TestChecker2(core_test.CoreTest):
    def inspect(self) :
        with open(f"{self.abs_working_dir()}/docker-compose.yml.tpl", 'r') as file:
            expectedDbPathReplacement = "'{{databaseDataPath}}:/var/lib/postgresql/data'"
            expectedEncryptedFilesReplacement = "'{{encryptedFilesPath}}:/root/app/data'"
            expectedAddedVolume = "./config/backend/email_templates:/root/app/dist/modules/mail/templates"
            filedata = file.read()
            errors = []
            
            if not expectedDbPathReplacement in filedata:
                errors.append(f"{expectedDbPathReplacement} was not replaced")
            if not expectedEncryptedFilesReplacement in filedata:
                errors.append(f"{expectedEncryptedFilesReplacement} was not replaced")
            if not expectedAddedVolume in filedata:
                errors.append(f"{expectedAddedVolume} was not added")
            if not os.path.exists(f"{self.WORKING_DIR}/config/backend/email_templates"):
                errors.append('Email templates were not copied')

            file.close()
            self.handle_inspection_errors(2, errors)

class TestChecker3(core_test.CoreTest):
    def inspect(self):
        with open(f"{self.abs_working_dir()}/config/backend/config.json.tpl", 'r') as file:
            expectedReplacement1 = '"secure": {{mailingTls}}'
            expectedReplacement2 = '"rejectUnauthorized": {{mailingRejectUnauthorized}}'
            filedata = file.read()
            errors = []
            
            if not expectedReplacement1 in filedata:
                errors.append(f"{expectedReplacement1} was not replaced")
            if not expectedReplacement2 in filedata:
                errors.append(f"{expectedReplacement2} was not replaced")

            file.close()
            self.handle_inspection_errors(2, errors)

class TestChecker4(core_test.CoreTest):
    def inspect(self):
        with open(f"{self.abs_working_dir()}/config/backend/config.json.tpl", 'r') as file:
            expectedReplacement1 = '"mode": "prod",'
            expectedReplacement2 = '"apiPath": "/api",'
            accessToken = '"accessToken"'
            refreshToken = '"refreshToken"'
            filedata = file.read()
            errors = []
            
            if not expectedReplacement1 in filedata:
                errors.append(f"{expectedReplacement1} was not replaced")
            if not expectedReplacement2 in filedata:
                errors.append(f"{expectedReplacement2} was not replaced")
            if not accessToken in filedata:
                errors.append("accessToken was not added")
            if not refreshToken in filedata:
                errors.append("refreshToken was not added")
            if "jwt" in filedata:
                errors.append("jwt was not removed")

            file.close()
            self.handle_inspection_errors(2, errors)