# $Id: new.py,v 1.8 2007/01/06 08:03:21 lmacken Exp $
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

import os
import util
import logging
import formencode

from os.path import join
from sqlobject import SQLObjectNotFound
from formencode import Invalid
from bodhi.model import Release, Package, PackageUpdate, Bugzilla, CVE
from turbogears import expose, controllers, validators, identity, config, url
from turbogears.widgets import (WidgetsList, TextField, SingleSelectField,
                                CheckBox, TextArea, CalendarDateTimePicker,
                                Form, TableForm, HiddenField, AutoCompleteField,
                                SubmitButton)

log = logging.getLogger(__name__)
update_types = ('bugfix', 'enhancement', 'security')

def get_releases():
    return [rel.long_name for rel in Release.select()]

#class PackageValidator(validators.FancyValidator):
#    messages = {
#            'bad_name' : 'Invalid package name; must be in package-version-'
#                         'release format',
#            'dupe'     : 'Package update %(nvr)s already exists'
#    }
#
#    def _to_python(self, value, state):
#        return value.strip()
#
#    def validate_python(self, value, state):
#        """
#        Run basic QA checks on the provided package name
#        """
#        # Make sure the package is in name-version-release format
#        if len(value.split('-')) < 3:
#            raise Invalid(self.message('bad_name', state), value, state)
#
#pkg_validator = PackageValidator()
#
#class AutoCompleteValidator(validators.Schema):
#    def _to_python(self, value, state):
#        text = value['text']
#        value['text'] = pkg_validator.to_python(text)
#        return value

#class UpdateFields(WidgetsList):
#    build = AutoCompleteField('build', label='Package',
#                            search_controller=url('/new/search'),
#                            search_param='name', result_name='pkgs',
#                            #validator=AutoCompleteValidator(),
## We're hardcoding the template to fix Ticket #32 until the AutoCompleteField
## can work properly in sub-controllers
#                            template="""\
#<div xmlns:py="http://purl.org/kid/ns#">
#    <script language="JavaScript" type="text/JavaScript">
#        AutoCompleteManager${field_id} = new AutoCompleteManager('${field_id}',
#        '${text_field.field_id}', '${hidden_field.field_id}',
#        '${search_controller}', '${search_param}', '${result_name}',${str(only_suggest).lower()},
#        '${tg.widgets}/turbogears.widgets/spinner.gif', 0.2);
#        addLoadEvent(AutoCompleteManager${field_id}.initialize);
#    </script>
#
#    ${text_field.display(value_for(text_field), **params_for(text_field))}
#    <img name="autoCompleteSpinner${name}" id="autoCompleteSpinner${field_id}" src="${tg.widgets}/turbogears.widgets/spinnerstopped.png" alt="" />
#    <div class="autoTextResults" id="autoCompleteResults${field_id}"/>
#    ${hidden_field.display(value_for(hidden_field), **params_for(hidden_field))}
#    </div>
#    """)
#    release = SingleSelectField(options=get_releases, validator=
#                                validators.OneOf(get_releases()))
#    type = SingleSelectField(options=update_types, validator=
#                             validators.OneOf(update_types))
#    bugs = TextField(validator=validators.UnicodeString())
#    cves = TextField(label='CVEs', validator=validators.UnicodeString())
#    notes = TextArea(validator=validators.UnicodeString(), rows=17, cols=65)
#    edited = HiddenField(default=None)
#
#update_form = TableForm(fields=UpdateFields(), submit_text='Submit',
#                        template="bodhi.templates.new",
#                        form_attrs={
#                            'onsubmit' :
#                                "$('bodhi-logo').style.display = 'none';"
#                                "$('wait').style.display = 'block';"
#                        })
#
#newform = TableForm('newupdate', fields=UpdateFields())


class NewUpdateForm(Form):
    template = "bodhi.templates.new"
    fields = [
            AutoCompleteField('build', label='Package',
                              search_controller=url('/new/search'),
                              search_param='name', result_name='pkgs',
# We're hardcoding the template to fix Ticket #32 until the AutoCompleteField
# can work properly in sub-controllers
                              template='bodhi.templates.packagefield'),
            SingleSelectField('release', options=get_releases,
                              validator=validators.OneOf(get_releases())),
            SingleSelectField('type', options=update_types,
                              validator=validators.OneOf(update_types)),
            TextField('bugs', validator=validators.UnicodeString()),
            TextField('cves', validator=validators.UnicodeString()),
            TextField('builds', validator=validators.UnicodeString()),
            TextArea('notes', validator=validators.UnicodeString(),
                     rows=17, cols=65),
            HiddenField('edited', default=None),
            SubmitButton('submit', label='Add Update')
    ]

newUpdateForm = NewUpdateForm(submit_text='Add Update',
                              form_attrs={
                                  'onsubmit' :
                                    "$('bodhi-logo').style.display = 'none';"
                                    "$('wait').style.display = 'block';"
                              })

class NewUpdateController(controllers.Controller):

    build_dir = config.get('build_dir')
    packages  = None

    def build_pkglist(self):
        """ Cache a list of packages used for the package AutoCompleteField """
        self.packages = os.listdir(self.build_dir)

    @identity.require(identity.not_anonymous())
    @expose(template="bodhi.templates.form")
    def index(self, *args, **kw):
        self.build_pkglist()
        return dict(form=newUpdateForm, values={}, action=url("/save"))

    @expose(format="json")
    def search(self, name):
        """
        Called automagically by the AutoCompleteWidget.
        If a package is specified (or 'pkg-'), return a list of available
        n-v-r's.  This method also auto-completes packages.
        """
        matches = []
        if not self.packages: self.build_pkglist()
        if name[-1] == '-' and name[:-1] and name[:-1] in self.packages:
            name = name[:-1]
            for version in os.listdir(join(self.build_dir, name)):
                for release in os.listdir(join(self.build_dir, name, version)):
                    matches.append('-'.join((name, version, release)))
        else:
            for pkg in self.packages:
                if name == pkg:
                    for version in os.listdir(join(self.build_dir, name)):
                        for release in os.listdir(join(self.build_dir, name,
                                                       version)):
                            matches.append('-'.join((name, version, release)))
                    break
                elif pkg.startswith(name):
                    matches.append(pkg)
        matches.reverse()
        return dict(pkgs=matches)
