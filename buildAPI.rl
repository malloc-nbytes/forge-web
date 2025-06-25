module BuildAPI

import "std/system.rl"; as sys

let files = sys::ls("/usr/include/forge");

let headers, names = ([], []);
foreach f in files {
    if f == "./conf.h" { continue; }

    let fd = open(f, "r");
    let content = fd.read();
    if len(content) >= 2 && content[0] == '/' && content[1] == '/' {
        fd.close();
        continue;
    }

    headers += [content];
    names += [f.split("/").rev()[0]];

    fd.close();
}

let docs_fd = open("index.org", "r");
let docs_content = docs_fd.read();

with parts = docs_content.split("# ENDDOCS")
in let docs = parts[0];
docs_fd.close();

let docs_write_fd = open("index.org", "w");
docs_write_fd.write(docs);
docs_write_fd.write("# ENDDOCS\n");
for i in 0 to len(headers) {
    docs_write_fd.write("** =forge/" + names[i] + "=\n");

    docs_write_fd.write("#+begin_src c\n");

    let lines = headers[i].split("\n");
    for j in 0 to len(lines) {
        if !(len(lines[j]) > 2 && lines[j][0] == '/' && lines[j][1] == '/') {
            docs_write_fd.write(lines[j]);
            docs_write_fd.write("\n");
        }
    }

    docs_write_fd.write('\n');
    docs_write_fd.write("#+end_src\n");
}
docs_write_fd.close();
