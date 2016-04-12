#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'uri'

uri = URI.parse(node['packer']['source_repo_url'])
golang_install_dir = "#{uri.host}#{uri.path}".gsub('.git', '')

include_recipe 'golang::default'

directory File.join(node['go']['gopath'], 'src/github.com/hashicorp') do
  owner 'root'
  group 'root'
  mode '00755'
  recursive true
  action :create
end

directory ::File.dirname(node['packer']['source_install_path']) do
  recursive true
end

git node['packer']['source_install_path'] do
  repository node['packer']['source_repo_url']
  reference node['packer']['source_revision']
  action :checkout
end

golang_package golang_install_dir do
  action :install
end

directory '/usr/local/bin' do
  recursive true
  action :create
end

link '/usr/local/bin/packer' do
  to node['packer']['source_install_path']
end
