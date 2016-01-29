program vtk

implicit none

real,dimension(:),allocatable::x,y,z,t,vx,vy,vz
real,dimension(:),allocatable::xs,ys,zs,ex,a1,a2,a3,a4,a5,a6,a7,a8,ftlm,raman
integer,dimension(:,:),allocatable::icon,iconsurf
real tim
integer nnode,nelem,nsurf,nelemsurf,mpe,npe,irec,nrec,itime,i,j,k,iunit,i1,i2,istep
integer nnx
character cs*3,ct*3,run*5,iq*1

open (76,file='input/topo_parameters.txt',status='old')
101 read (76,'(a)') iq
if (iq.eq.'$') goto 101
backspace (76)
read (76,'(a5)') run
close (76)

print*,'Doing temperature and velocity'

open (77,file=run//'/Pecube.out',status='old',access='direct',recl=16)
read (77,rec=1) nnode,nelem,mpe,tim
close (77)

open (77,file=run//'/Pecube.out',status='old',access='direct',recl=4)
nrec=1
1 read (77,rec=(nrec-1)*(4+7*nnode+mpe*nelem)+1) nnx
if (nnx.lt.0) goto 999
print*,'Record',nrec
nrec=nrec+1
goto 1
999 nrec=nrec-1
close (77)

open (77,file=run//'/Pecube.out',status='old',access='direct',recl=4*(4+7*nnode+mpe*nelem))

allocate (x(nnode),y(nnode),z(nnode),t(nnode))
allocate (vx(nnode),vy(nnode),vz(nnode))
allocate (icon(mpe,nelem))

do irec=0,nrec-1

print*,'doing record ',irec,'out of',nrec

read (77,rec=irec+1) nnode,nelem,mpe,tim,(x(i),i=1,nnode),(y(i),i=1,nnode),(z(i),i=1,nnode),(t(i),i=1,nnode), &
                     (vx(i),i=1,nnode),(vy(i),i=1,nnode),(vz(i),i=1,nnode),(icon(1:mpe,i),i=1,nelem)

write(cs,'(i3)') irec
if (irec.lt.10) cs(1:2)='00'
if (irec.lt.100) cs(1:1)='0'
itime=int(tim)
write(ct,'(i3)') itime
if (itime.lt.10) ct(1:2)='00'
if (itime.lt.100) ct(1:1)='0'

iunit=30

open(unit=iunit,file='VTK/Pecube'//cs//'.vtk')
write(iunit,'(a)')'# vtk DataFile Version 3.0'
write(iunit,'(a)')'velocities'
write(iunit,'(a)')'ASCII'
write(iunit,'(a)')'DATASET UNSTRUCTURED_GRID'
write(iunit,'(a7,i10,a6)')'POINTS ',nnode,' float'

  do i=1,nnode
  write(iunit,'(3f16.11)') x(i),y(i),z(i)
  enddo

print*,mpe

  if (mpe.eq.8) then

  write(iunit,'(A6, 2I10)') 'CELLS ',nelem,9*nelem
    do i=1,nelem
    write(iunit,'(9I10)')8,icon(1,i)-1,icon(2,i)-1,icon(3,i)-1,icon(4,i)-1, &
                           icon(5,i)-1,icon(6,i)-1,icon(7,i)-1,icon(8,i)-1
    enddo
  write(iunit,'(A11, I10)') 'CELL_TYPES ',nelem
    do k=1,nelem
    write(iunit,'(I2)')12 ! octree  (8 nodes)
    enddo

  else

  write(iunit,'(A6, 2I10)') 'CELLS ',nelem,7*nelem
    do i=1,nelem
    write(iunit,'(9I10)')6,icon(1,i)-1,icon(3,i)-1,icon(2,i)-1, &
                           icon(4,i)-1,icon(6,i)-1,icon(5,i)-1
    enddo
  write(iunit,'(A11, I10)') 'CELL_TYPES ',nelem
    do k=1,nelem
    write(iunit,'(I2)')13 ! octree  (6 nodes)
    enddo

 endif

write(iunit,'(a11,i10)')'POINT_DATA ',nnode

write(iunit,'(a)')'SCALARS Temperature float 1'
write(iunit,'(a)')'LOOKUP_TABLE default'
    do i=1,nnode
    write(iunit,'(f18.13)') t(i)
    enddo

write(iunit,'(a)')'VECTORS velo float'
    do i=1,nnode
    write(iunit,'(3f18.13)') vx(i),vy(i),vz(i)
    enddo

close (iunit)

enddo

deallocate (x,y,z,t)

close (77)

print*,'Doing Ages and topo'

open (77,file=run//'/Ages.out',status='old',access='direct',recl=16)
read (77,rec=1) nsurf,nelemsurf,npe,tim
close (77)

open (77,file=run//'/Ages.out',status='old',access='direct',recl=4)
nrec=1
2 read (77,rec=(nrec-1)*(4+14*nsurf+npe*nelemsurf)+1) nnx
if (nnx.lt.0) goto 998
print*,'Record',nrec
nrec=nrec+1
goto 2
998 nrec=nrec-1
close (77)

open (77,file=run//'/Ages.out',status='old',access='direct',recl=4*(4+14*nsurf+npe*nelemsurf))

allocate (xs(nsurf),ys(nsurf),zs(nsurf),ex(nsurf))
allocate (a1(nsurf),a2(nsurf),a3(nsurf),a4(nsurf),a5(nsurf))
allocate (a6(nsurf),a7(nsurf),a8(nsurf))
allocate (ftlm(nsurf),raman(nsurf))
allocate (iconsurf(npe,nelemsurf))

do irec=0,nrec-1

print*,'doing record ',irec,'out of',nrec

read (77,rec=irec+1) nsurf,nelemsurf,npe,tim,xs,ys,zs,ex,a1,a2,a3,a4,a5,a6,a7,a8,ftlm,raman,iconsurf

write(cs,'(i3)') irec
if (irec.lt.10) cs(1:2)='00'
if (irec.lt.100) cs(1:1)='0'
itime=int(tim)
write(ct,'(i3)') itime
if (itime.lt.10) ct(1:2)='00'
if (itime.lt.100) ct(1:1)='0'

iunit=30

open(unit=iunit,file='VTK/Ages'//cs//'.vtk')
write(iunit,'(a)')'# vtk DataFile Version 3.0'
write(iunit,'(a)')'velocities'
write(iunit,'(a)')'ASCII'
write(iunit,'(a)')'DATASET UNSTRUCTURED_GRID'
write(iunit,'(a7,i10,a6)')'POINTS ',nsurf,' float'

    do i=1,nsurf
    write(iunit,'(3f16.11)') xs(i),ys(i),zs(i)
    enddo

  if (npe.eq.4) then

  write(iunit,'(A6, 2I10)') 'CELLS ',nelemsurf,5*nelemsurf
    do i=1,nelemsurf
    write(iunit,'(9I10)')4,iconsurf(1:npe,i)-1
    enddo

  write(iunit,'(A11, I10)') 'CELL_TYPES ',nelemsurf
    do k=1,nelemsurf
    write(iunit,'(I2)')9 ! octree  (8 nodes)
    enddo

  else

  write(iunit,'(A6, 2I10)') 'CELLS ',nelemsurf,4*nelemsurf
    do i=1,nelemsurf
    write(iunit,'(9I10)')3,iconsurf(1:npe,i)-1
    enddo

  write(iunit,'(A11, I10)') 'CELL_TYPES ',nelemsurf
    do k=1,nelemsurf
    write(iunit,'(I2)')5 ! octree  (8 nodes)
    enddo

  endif

write(iunit,'(a11,i10)')'POINT_DATA ',nsurf

write(iunit,'(a)')'SCALARS ExhumationRate float 1'
write(iunit,'(a)')'LOOKUP_TABLE default'
    do i=1,nsurf
    write(iunit,'(f18.13)') ex(i)
    enddo

write(iunit,'(a)')'SCALARS ApatiteHeAge float 1'
write(iunit,'(a)')'LOOKUP_TABLE default'
    do i=1,nsurf
    write(iunit,'(f18.13)') a1(i)
    enddo

write(iunit,'(a)')'SCALARS ZirconHeAge float 1'
write(iunit,'(a)')'LOOKUP_TABLE default'
    do i=1,nsurf
    write(iunit,'(f18.13)') a2(i)
    enddo

write(iunit,'(a)')'SCALARS ApatiteFTAge float 1'
write(iunit,'(a)')'LOOKUP_TABLE default'
    do i=1,nsurf
    write(iunit,'(f18.13)') a3(i)
    enddo

write(iunit,'(a)')'SCALARS ZirconFTAge float 1'
write(iunit,'(a)')'LOOKUP_TABLE default'
    do i=1,nsurf
    write(iunit,'(f18.13)') a4(i)
    enddo

write(iunit,'(a)')'SCALARS KsparArgonAge float 1'
write(iunit,'(a)')'LOOKUP_TABLE default'
    do i=1,nsurf
    write(iunit,'(f18.13)') a5(i)
    enddo

write(iunit,'(a)')'SCALARS BiotiteArgonAge float 1'
write(iunit,'(a)')'LOOKUP_TABLE default'
    do i=1,nsurf
    write(iunit,'(f18.13)') a6(i)
    enddo

write(iunit,'(a)')'SCALARS MuscoviteArgonAge float 1'
write(iunit,'(a)')'LOOKUP_TABLE default'
    do i=1,nsurf
    write(iunit,'(f18.13)') a7(i)
    enddo

write(iunit,'(a)')'SCALARS HornblendeArgonAge float 1'
write(iunit,'(a)')'LOOKUP_TABLE default'
    do i=1,nsurf
    write(iunit,'(f18.13)') a8(i)
    enddo

write(iunit,'(a)')'SCALARS ApatiteMeanFTLength float 1'
write(iunit,'(a)')'LOOKUP_TABLE default'
    do i=1,nsurf
    write(iunit,'(f18.13)') ftlm(i)
    enddo

write(iunit,'(a)')'SCALARS RamanPeakT float 1'
write(iunit,'(a)')'LOOKUP_TABLE default'
    do i=1,nsurf
    write(iunit,'(f18.13)') raman(i)
    enddo

close (iunit)

enddo

close (77)

end program vtk
