```console
foo@bar:~$ ls 
input.md

foo@bar:~$ cat input.md
````plantuml
Bob -> Alice : Hello!
````

foo@bar:~$ alias pandoc="docker run -it -v `pwd`:/var/docs melobenja/pandoc-plantuml-mermaid:v0.0.2"

foo@bar:~$ pandoc -o output.odt input.md

foo@bar:~$ ls
intput.md      output.odt      plantuml-images
```
