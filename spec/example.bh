import git:bash_shortcuts as short

#[windows]
fun cleanUp() {
    home = p"./ast/ast.sh"
    home.exists()
    contents = home.ls()
}

fun newline<windows>() {
    println('hello')
}

fun checkInstallation() {
    path[] package = ['mysql']
    string about = 'bossy'
    package vim.installed()
    if !+vim.installed() {
        +vim.install()
    }
    for +pkg in ['php-mysql', 'php-curl', 'php-fpm'] {
        if !+pkg.installed(){
            +pkg.install()
        }
    }
    if p"ast/".exists() {
        p"ast/token/".mkdir()
        name = p"ast/token/ast.sh".touch()
        name.ext()
        name.base()
    }
    output = if +vscode.installed() {
        +vscode.remove()
    }
    name = ""
    if name.empty() {
        return "", .fail
        exit .fail
        return .fail
    }
    shell = @htop | @sed(n=1,s="|").replace('yes','nohl') | echo
    @bash(htop | @sed.n(1).s('yes','nohl') | echo)!
    # don't allow boushisms in raw
    @raw(htop | sed -n 1 | echo)!!
    return output | @sed(n=1) | @cut(d=",") , .success
}

fun main() {
    # maybe no arg funcs could have no parens
    checkInstallation()
    cleanUp()
    eof 'data.log' {
        "completed download"
    }
}
