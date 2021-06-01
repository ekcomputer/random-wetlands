# function to simply move grd files in $1 to $1/default_grd
# Run when simply needing to move files to default_grd folder

for file in `find *34509* -name *.grd`; do mv $file atqasu_34509_19063_001_190913_L090_CX_01/default_grd/; done
