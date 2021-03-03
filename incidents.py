import pandas as pd


while True:
    try:
        inputfile=input('Name of the file: ')
        file=open(inputfile)
    except FileNotFoundError:
        print('Please enter the name of the file you wish to transform.')
        
        continue
    else:
        print('Processing file ',inputfile)
        break          

while True:
    outputfile=input('Name of the outputfile: ')
    
    if (outputfile==""):
        print('Please enter the name of the output file.\nNote that if it does not exist, we will create a new one with that name.')
    else:
        break


file=open(inputfile)
#file=open("incidentesRaw.csv")
lst=file.read()
lst=lst.splitlines()

#ldic=[]
aux=0
nlst=[]
for i in lst:
    k=len(i)
    aux=aux+1  
    #print(aux)
    if(k>1 and k<7 and aux<33):
        k=k/2
        nlst.append(i[int(k):]) 
        #pd.DataFrame()
        
        
print("Please find below the list of incidents per day, you may want to review if the following data makes sense to you:\n",nlst, "\nProcessing the list into a column... Please wait.")      

file=open(outputfile, "a")    
for i in nlst:
    file.write(i)
    file.write("\n")



file.close()   
print("Dear Lady, your file has been generated with name <<",outputfile, ">> successfully.")
