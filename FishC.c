    #include <stdio.h>   //all linux dependent
    #include <string.h>
    #include <stdlib.h>
    #include <ctype.h>
    #include <sys/utsname.h>
    #include <unistd.h>
    #include <sys/stat.h>
    #include <dirent.h>

    void PRINT(const char *s) {
        while (*s) {

            s++;
        }
    }
// COLORS!
#define RED   0xFF0000
#define BLUE  0x0000FF
#define GREEN 0x00FF00


    void Chat(const char *in) {

    }

    int parse(const char *in, char *cmd, char *args) {
        char temp[256];
        strncpy(temp, in, sizeof(temp));
        temp[sizeof(temp)-1] = '\0';

        temp[strcspn(temp, "\n")] = 0;

        size_t len = strlen(temp);

        char *semi = strchr(temp, ';');
        if (!semi) return 0;
        if (semi != temp + len - 1) return 0;

        temp[len-1] = '\0';

        while (len > 1 && isspace((unsigned char)temp[len-2])) {
            temp[len-2] = '\0';
            len--;
        }

        char *tok = strtok(temp, " ");
        if (!tok)
            return 0;

        strcpy(cmd, tok);

        char *rest = strtok(nullptr, "");
        if (rest)
            strcpy(args, rest);
        else
            args[0] = '\0';

        return 1;
    }

    void Fish(const char *cmd, const char *args) {
                  //fishC
        if (strcmp(cmd, "HELP") == 0) {
            printf("Available commands:\n");
            printf("HELP;\n");
            printf("PRINT <text>;\n");
            printf("DELETE <file>;\n");
            printf("MAKEFILE <name>;\n");
            printf("MAKEFOLDER <name>;\n");
            printf("EDIT <file>;\n");
            printf("EXECUTE <program>;\n");
            printf("EXIT;\n");
            printf("RENAME <old> <new>;\n");
            printf("GOTO <dir>;\n");
            printf("SYSINFO;\n");
        }
        //PRINT
        else if (strcmp(cmd, "PRINT") == 0) {
            printf("%s\n", args);
        }
       //EXIT
        else if (strcmp(cmd, "EXIT") == 0) {
            printf("EXITED FISH SHELL\n");
            exit(0);
        }
       //SYSINFO
        else if (strcmp(cmd, "SYSINFO") == 0) {
            printf("SYSINFO:\n");
            
            struct utsname name;
            if (uname(&name) == -1) {
                perror("uname");
                return;
            }

            printf("Operating system name = %s.\n", name.sysname);
            printf("Node (network) name = %s.\n", name.nodename);
            printf("Release level = %s.\n", name.release);
            printf("Version level = %s.\n", name.version);
            printf("Machine = %s.\n", name.machine);

        }
        // DELETE
        else if (strcmp(cmd, "DELETE") == 0) {
            if (args[0] == '\0') {
                printf("✘ DELETE needs a file name\n");
                return;
            }

            if (remove(args) == 0)
                printf("✔ Deleted %s\n", args);
            else
                perror("✘ DELETE failed");
        }
        //MAKEFILE
        else if (strcmp(cmd, "MAKEFILE") == 0) {
            printf("MAKEFILE:\n");
            if (args[0] == '\0') {
                printf("✘ MAKEFILE needs a file name\n");
                return;
            }

            FILE *f = fopen(args, "w");
            if (!f) {
                perror("✘ MAKEFILE failed");
                return;
            }
            fclose(f);
            printf("✔ Created file %s\n", args);
        }
        //MAKEFOLDER
        else if (strcmp(cmd, "MAKEFOLDER") == 0) {
            printf("MAKEFOLDER:\n");
            if (args[0] == '\0') {
                printf("✘ MAKEFOLDER needs a folder name\n");
                return;
            }

            if (mkdir(args, 0755) == 0)
                printf("✔ Created folder %s\n", args);
            else
                perror("✘ MAKEFOLDER failed");

        }
        //EDIT
        else if (strcmp(cmd, "EDIT") == 0) {
            printf("EDIT:\n");
            if (args[0] == '\0') {
                printf("✘ EDIT needs a file name\n");
                return;
            }

            char cmdline[300];
            snprintf(cmdline, sizeof(cmdline), "nano %s", args);
            system(cmdline);
        }
        //EXECUTE
        else if (strcmp(cmd, "EXECUTE") == 0) {
            printf("EXECUTE:\n");
            if (args[0] == '\0') {
                printf("✘ EXECUTE needs a program\n");
                return;
            }

            int result = system(args);
            printf("Program exited with code %d\n", result);
        }
        //GOTO
        else if (strcmp(cmd, "GOTO") ==0) {
            printf("GOTO:\n");
            if (args[0] == '\0') {
                printf("✘ GOTO needs a directory\n");
                return;
            }

            if (chdir(args) == 0)
                printf("✔ Entered %s\n", args);
            else
                perror("✘ GOTO failed");
        }
        //RENAME
        else if (strcmp(cmd, "RENAME") == 0) {
            printf("RENAME:\n");
            char oldname[128], newname[128];

            if (sscanf(args, "%127s %127s", oldname, newname) != 2) {
                printf("✘ RENAME <old> <new>\n");
                return;
            }

            if (rename(oldname, newname) == 0)
                printf("✔ Renamed %s → %s\n", oldname, newname);
            else
                perror("✘ RENAME failed");
        }
        else if (strcmp(cmd, "VIEW") ==0) {
            DIR *d = opendir(".");
            if (!d) {
                printf("✘ cannot open directory\n");
                return;
            }

            struct dirent *e;
            while ((e = readdir(d)) != NULL) {
                if (strcmp(e->d_name, ".") == 0 || strcmp(e->d_name, "..") == 0)
                    continue;
                printf("%s\n", e->d_name);
            }

            closedir(d);
        }
        else {
            printf("✘ Unknown command: %s\n", cmd);
        }

    }

    int main() {
        char buf[256];
        char cmd[128];
        char args[128];

        while (1) {
            printf("⟦FISH⟧» ");
            fflush(stdout);

            if (!fgets(buf, sizeof(buf), stdin))
                break;

            if (!parse(buf, cmd, args))
                continue;

            Fish(cmd, args);
            Chat(buf);
        }

        return 0;
    }
