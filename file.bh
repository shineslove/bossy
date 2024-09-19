import pkg
import os
import curl
import xargs
import sed
import awk
import git:pure-bash/shortcuts as shortcuts
# alias shortcuts="pure-bash/shortcuts"
shortcuts.remove(' ')

# builtin: os?, sed, awk, xargs, pkg
# Types: Command, string, int? , option?, result?, Dir?, bool?
# unwrap sends to /dev/null !/~
# file type automatically has cat, touch
# directory type has mkdir, size, ls?
# @os.path or @os.dir Dir type
# try for result type?
# @pkg.installed('nano'), @pkg.update(upgrade=true)
# keywords bash + types?
# @(commands..).or_exit()?
# ^panic?
# and/or added?
# empty/none support?
# macros or header to specify platform
# os.read!() panics? or strict mode?

fun checkInstallation () {
    # can't assign bool
    vim = @pkg.installed('vim')
    php_reqs = @pkg.installed(['php-mysql','php-curl', 'php-sockets'])
    #unsure syntax
    php_reqs = ~('php-mysql','php-curl','php-sockets').is_installed
    php_reqs = :('php-mysql','php-curl','php-sockets').is_installed?
    php_reqs = %('php-mysql','php-curl','php-sockets').is_installed?
    # do this instead
    if @pkg.installed('vim') {
        vim.install(y=true,force=true)
        vim.install().yes().force()
        #unsure syntax
        ~vim.is_installed
        #better syntax?
        :vim.is_installed
    }
    if :vim.installed? {
    }
    if %vim.installed() {
    }
    file = @os.readfile('data.log')
    file = :read('data.log')
    file = @cat('data.log')
    file = @echo('data.log', data)
    @println(data)
    output = ~write('data.log',data)
    file_alt = @os.read('data.log')
    txt_file = @file('data.log')
    if not txt_file.exists() {
        txt_file.touch()
    }
    command: Command = @(psql)
    if command.exists() {
        command.add("-u root -p root") | grep -i psql | @sed.strip() | @sed.compile() | @awk.print()
    }
    raw_cmd: String = r#'ps -aux | grep -i node'
    #if ~psql.exists() {
    if :psql.exists() {
        #unsure syntax
        ~psql.args('-u root -p root') | grep -i psql | @sed.strip()
        ~psql.{'-u root -p root'} | grep -i psql | @sed.strip
        :psql('-u root -p root')
        |> grep -i psql
        |> @sed.strip
    }
    url: string = "https://example.com/data"
    data: Command! = @curl(url, redirect=True, output="data.json").discard_err()
    data_alt: Command! = @curl.url("google.com").redirect().output("data.json").discard_err()
    data_alt_two = @curl.url("google.com").redirect().output("data.json")!

    eof 'data.txt' {
        "Here is the infomation that
        you wanted after all."
    }

    eof 'main.py' : python {
        "import sys
        sys.exit()"
    }

    #raw bash? (unsafe?)
    ~(kill %2 | ps -aux | grep -i bash)
}

checkInstallation()

# implement xargs package, parallel package, find, sed, awk
# wrapper around these components
