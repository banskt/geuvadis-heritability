options <- commandArgs(trailingOnly = TRUE)
infile <- options[1]
outfile <- options[2]

lds_seg = read.table(infile,header=T,colClasses=c("character",rep("numeric",8)))
quartiles=summary(lds_seg$ldscore_region)

lb1 = which(lds_seg$ldscore_region <= quartiles[2])
lb2 = which(lds_seg$ldscore_region > quartiles[2] & lds_seg$ldscore_region <= quartiles[3])
lb3 = which(lds_seg$ldscore_region > quartiles[3] & lds_seg$ldscore_region <= quartiles[5])
lb4 = which(lds_seg$ldscore_region > quartiles[5])

lb1_snp = lds_seg$SNP[lb1]
lb2_snp = lds_seg$SNP[lb2]
lb3_snp = lds_seg$SNP[lb3]
lb4_snp = lds_seg$SNP[lb4]

write.table(lb1_snp, paste(outfile,"1.txt", sep=""), row.names=F, quote=F, col.names=F)
write.table(lb2_snp, paste(outfile,"2.txt", sep=""), row.names=F, quote=F, col.names=F)
write.table(lb3_snp, paste(outfile,"3.txt", sep=""), row.names=F, quote=F, col.names=F)
write.table(lb4_snp, paste(outfile,"4.txt", sep=""), row.names=F, quote=F, col.names=F)
