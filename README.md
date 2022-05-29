# AfterInstall

Script de pós instalação para Windows usando [powershell](https://docs.microsoft.com/pt-br/powershell/scripting/overview?view=powershell-7.2) e [aria2](https://aria2.github.io/).

Para usar o script, abra um terminal, digite ```powershell``` e informe o seguinte:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
``` 
Logo após isso, vá ate o diretório onde baixou o script e digite:

```powershell
.\Installer.ps1
```
O script pedirá permissão de administrador, baixará algumas dependências e mostrará um menu, onde poderá ser selecionada uma ação a ser executada.
Totalmente online: baixa os programas, salva em uma pasta e instala silenciosamente se possível.

Leve o script para onde quiser e execute.

*Inspirado na ferramenta [Fedy](https://github.com/rpmfusion-infra/fedy) mas sem interface gráfica!*

 
 
 
 
 
