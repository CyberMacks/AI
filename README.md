# AfterInstall

Script de pós instalação para Windows 10/11 64 bits usando [powershell](https://docs.microsoft.com/pt-br/powershell/scripting/overview?view=powershell-7.2) e [aria2](https://aria2.github.io/).

Abra um terminal powershell como administrador, e digite:

```powershell
Set-ExecutionPolicy RemoteSigned
``` 
ou
```powershell
Set-ExecutionPolicy Bypass
``` 
Logo após isso, vá ate o diretório onde baixou o script e digite:

```powershell
.\Installer.ps1
```
O script baixará algumas dependências e mostrará um menu, onde poderá ser selecionada uma ação a ser executada.<br>
Totalmente online, salva em uma pasta e instala silenciosamente se possível.

Leve o script para onde quiser e execute seguindo os passos acima!

*Inspirado na ferramenta [Fedy](https://github.com/rpmfusion-infra/fedy) !*

Script válido somente para Windows 10 64 bits e Windows 11 64 bits.


 
