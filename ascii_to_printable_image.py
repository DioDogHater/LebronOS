file_name = input("Enter image file name: ")

label_name = input("Enter sector label name: ")

background = input("Background character: ")

image = ""

def find_start_char(s : str, t):
    i = 0
    while s[i] == t:
        i += 1
    return i

print("Please input the ascii image:")
while True:
    line = input("> ")
    if line == "quit": break
    if len(line.strip(background)) == 0: continue
    offset = f"{hex(find_start_char(line,background)+128)},"
    image += "db "+offset+"\""+line.strip(background).replace(" ",".")+"\",10\n"

with open("src/"+file_name,"w") as file:
    file.write(file_name.split(".")[0]+"_image equ $-"+label_name+"\n")
    file.write(image+"db 0\n")

print(f"Successfully wrote file src/{file_name} with image data named \"{file_name.split(".")[0]}_image\"!")
