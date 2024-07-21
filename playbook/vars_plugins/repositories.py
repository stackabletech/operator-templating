DOCUMENTATION = '''
    name: repositories
    version_added: "2.10"  # for collections, use the collection version, not the Ansible version
    short_description: Load Stackable operator repositories
    description: Load Stackable operator repositories
'''
from ansible.plugins.vars import BaseVarsPlugin
from ansible.errors import AnsibleError
import yaml

class VarsModule(BaseVarsPlugin):
    def get_vars(self, loader, path, entities):
        with open('/home/sliebau/IdeaProjects/stackable/operator-templating/.github/workflows/generate_prs.yml', 'r') as file:
            data = yaml.safe_load(file)
            return data['jobs']['create-prs']['strategy']['matrix']
