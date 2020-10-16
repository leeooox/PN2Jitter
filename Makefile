
all: 
	nim c -d:release --opt:size --passL:-s --app:gui PN2JitterGUI.nim

clean:
	rm *.exe
