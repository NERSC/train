!=============================================================================================
!
! Hack this Kernel
!
!==============================================================================================

program hackakernel

implicit none

integer :: n1
integer :: ispin, iw, ifreq, ijk
integer :: number_bands,nvband,ncouls,ngpown,nfreqeval,nFreq
integer :: my_igp, ig, igmax
complex(kind((1.0d0,1.0d0))) :: achstemp,achxtemp,mygpvar1,schstemp,schs,sch,scht
complex(kind((1.0d0,1.0d0))), allocatable :: leftvector(:,:), rightvector(:,:), I_epsR_array(:,:,:), I_epsA_array(:,:,:),matngmatmgpD(:,:),dFreqBrd(:)
complex(kind((1.0d0,1.0d0))) :: schD,achsDtemp,schsDtemp
complex(kind((1.0d0,1.0d0))), allocatable :: achDtemp(:),ach2Dtemp(:),achDtemp_cor(:),achDtemp_corb(:)
complex(kind((1.0d0,1.0d0))), allocatable :: schDi(:),schDi_cor(:),schDi_corb(:),sch2Di(:), schDt_array(:)
complex(kind((1.0d0,1.0d0))) :: schDt,schDtt,sch2dt,sch2dtt,I_epsRggp_int, I_epsAggp_int
complex(kind((1.0d0,1.0d0))) :: schDttt,schDttt_cor
complex(kind((1.0d0,1.0d0))) :: schDt_avg, schDt_right, schDt_left, schDt_lin, schDt_lin2, schDt_lin3
complex(kind((1.0d0,1.0d0))) :: cedifft_coh,cedifft_cor
real(kind(1.0d0)) :: cedifft_zb,intfact,cedifft_zb_left,cedifft_zb_right
real(kind(1.0d0)) :: e_n1kq, e_lk, dw, prefactor, wx
real(kind(1.0d0)), allocatable :: ekq(:,:), vcoul(:), wxi(:), dFreqGrid(:), pref(:)
real(kind(1.0d0)) :: starttime, endtime
real(kind(1.0d0)) :: starttime_a, endtime_a
real(kind(1.0d0)) :: time_a
real(kind(1.0d0)) :: starttime_ch, endtime_ch
real(kind(1.0d0)) :: time_b 
real(kind(1.0d0)) :: time_c 
logical :: flag_occ

time_a = 0D0
time_b = 0D0
time_c = 0D0

! We start off in the body of loop over the various tasks. Each MPI task has communicated data it owns to everyone

! These should typically be read in

      number_bands = 96
      nvband = 4
      ncouls = 8000
      ngpown = 100
      nFreq = 240
      nfreqeval = 6000

! ngpown = ncouls / (simulates number of mpi tasks)

      e_lk = 10D0
      prefactor = 0.5D0 / 3.14D0

      ALLOCATE(vcoul(ncouls))
      vcoul = 1D0

      ALLOCATE(ekq(number_bands,1))
      dw = -10D0
      do ijk = 1, number_bands
        ekq(ijk,1) = dw 
        dw = dw + 1D0
      enddo

      ALLOCATE(rightvector(ncouls,number_bands))
      ALLOCATE(leftvector(ncouls,number_bands))
      leftvector = (0.5D0,0.5D0)
      rightvector = (0.5D0,0.5D0)

      ALLOCATE(I_epsR_array(ncouls,ngpown,nFreq))
      I_epsR_array = (0.5D0,0.5D0)
      ALLOCATE(I_epsA_array(ncouls,ngpown,nFreq))
      I_epsA_array = (0.5D0,-0.5D0)

      ALLOCATE(matngmatmgpD(ncouls,ngpown))

      ALLOCATE(dFreqGrid(nFreq))
      dw = 0D0
      do ijk = 1, nFreq
        dFreqGrid(ijk) = dw
        dw = dw + 2D0
      enddo

      ALLOCATE(pref(nFreq))
      do ifreq=1,nFreq
        if (ifreq .lt. nFreq) then
          pref(ifreq)=(dFreqGrid(ifreq+1)-dFreqGrid(ifreq))/3.14d0
        else
          pref(ifreq)=pref(ifreq-1)
        endif
      enddo
      pref(1)=pref(1)*0.5d0
      pref(nFreq)=pref(nFreq)*0.5d0

      ALLOCATE(dFreqBrd(nFreq))
      dFreqBrd = (0D0,0.1D0)

      ALLOCATE(achDtemp(nfreqeval))
      achDtemp = 0D0
      ALLOCATE(achDtemp_cor(nfreqeval))
      achDtemp_cor = 0D0
      ALLOCATE(achDtemp_corb(nfreqeval))
      achDtemp_corb = 0D0
      ALLOCATE(ach2Dtemp(nfreqeval))
      ach2Dtemp = 0D0
      ALLOCATE(schDi(nfreqeval))
      schDi=0D0
      ALLOCATE(schDi_cor(nfreqeval))
      schDi_cor=0D0
      ALLOCATE(schDi_corb(nfreqeval))
      schDi_corb=0D0
      ALLOCATE(sch2Di(nfreqeval))
      sch2Di=0D0
      ALLOCATE(wxi(nfreqeval))
      wxi=0D0

      write(6,*) "Starting loop"

      call timget(starttime)

      do n1=1,number_bands

! energy of the |n1,k-q> state

        e_n1kq = ekq(n1,1)

        flag_occ = (n1.le.nvband)

        do iw=1,nfreqeval
          wx = 0D0 - e_n1kq + (iw-1)*0.5D0
          wxi(iw) = wx
        enddo

! JRD compute the static CH

        call timget(starttime_a)

        do my_igp = 1, ngpown
          if (my_igp .gt. ncouls .or. my_igp .le. 0) cycle

          igmax=ncouls

          mygpvar1 = CONJG(leftvector(my_igp,n1))

          do ig = 1, igmax
            matngmatmgpD(ig,my_igp) = rightvector(ig,n1) * mygpvar1
          enddo
        enddo

        call timget(endtime_a)
        time_a = time_a + endtime_a - starttime_a

        schDi = (0D0,0D0)
        schDi_cor = (0D0,0D0)
        schDi_corb = (0D0,0D0)
        sch2Di = (0D0,0D0)

! JRD: Now do CH term
          
        ALLOCATE(schDt_array(nFreq))
        schDt_array(:) = 0D0

        call timget(starttime_ch)
 
        schdt_array = 0D0
        do ifreq=1,nFreq

            schDt = (0D0,0D0)

            do my_igp = 1, ngpown

              if (my_igp .gt. ncouls .or. my_igp .le. 0) cycle

              igmax=ncouls

              schDtt = (0D0,0D0)
              do ig = 1, igmax
                I_epsRggp_int = I_epsR_array(ig,my_igp,ifreq)
                I_epsAggp_int = I_epsA_array(ig,my_igp,ifreq)
                schD=I_epsRggp_int-I_epsAggp_int
                schDtt = schDtt + matngmatmgpD(ig,my_igp)*schD
              enddo
              schdt_array(ifreq) = schdt_array(ifreq) + schDtt
            enddo

        enddo

        call timget(endtime_ch)
        time_b = time_b + endtime_ch - starttime_ch
        call timget(starttime_ch)

        do ifreq=1,nFreq

            schDt = schDt_array(ifreq)

            cedifft_zb = dFreqGrid(ifreq)
            cedifft_coh = CMPLX(cedifft_zb,0D0)- dFreqBrd(ifreq)

            if (ifreq .ne. 1) then 
              cedifft_zb_right = cedifft_zb
              cedifft_zb_left = dFreqGrid(ifreq-1)
              schDt_right = schDt
              schDt_left = schDt_array(ifreq-1)
              schDt_avg = 0.5D0 * ( schDt_right + schDt_left )
              schDt_lin = schDt_right - schDt_left
              schDt_lin2 = schDt_lin/(cedifft_zb_right-cedifft_zb_left)
            endif

! The below two lines are for sigma1 and sigma3
            if (ifreq .ne. nFreq) then
              schDi(:) = schDi(:) - CMPLX(0.d0,pref(ifreq)) * schDt / ( wxi(:)-cedifft_coh)
              schDi_corb(:) = schDi_corb(:) - CMPLX(0.d0,pref(ifreq)) * schDt / ( wxi(:)-cedifft_cor)
            endif
            if (ifreq .ne. 1) then
              do iw = 1, nfreqeval
!These lines are for sigma2
                intfact=abs((wxi(iw)-cedifft_zb_right)/(wxi(iw)-cedifft_zb_left))
                if (intfact .lt. 1d-4) intfact = 1d-4
                if (intfact .gt. 1d4) intfact = 1d4
                intfact = -log(intfact)
                sch2Di(iw) = sch2Di(iw) - CMPLX(0.d0,prefactor) * schDt_avg * intfact
!These lines are for sigma4
                if (flag_occ) then
                  intfact=abs((wxi(iw)+cedifft_zb_right)/(wxi(iw)+cedifft_zb_left))
                  if (intfact .lt. 1d-4) intfact = 1d-4
                  if (intfact .gt. 1d4) intfact = 1d4
                  intfact = log(intfact)
                  schDt_lin3 = (schDt_left + schDt_lin2*(-wxi(iw)-cedifft_zb_left))*intfact
                else 
                  schDt_lin3 = (schDt_left + schDt_lin2*(wxi(iw)-cedifft_zb_left))*intfact
                endif
                schDt_lin3 = schDt_lin3 + schDt_lin
                schDi_cor(iw) = schDi_cor(iw) - CMPLX(0.d0,prefactor) * schDt_lin3
              enddo
            endif
        enddo

        DEALLOCATE(schDt_array)

        call timget(endtime_ch)
        time_c = time_c + endtime_ch - starttime_ch

        do iw = 1, nfreqeval
            
          achDtemp(iw) = achDtemp(iw) + schDi(iw)
          achDtemp_cor(iw) = achDtemp_cor(iw) + schDi_cor(iw)
          achDtemp_corb(iw) = achDtemp_corb(iw) + schDi_corb(iw)
          ach2Dtemp(iw) = ach2Dtemp(iw) + sch2Di(iw)

        enddo ! over iw

      enddo ! over ipe bands (n1)

      call timget(endtime)

      DEALLOCATE(vcoul)
      DEALLOCATE(rightvector)
      DEALLOCATE(leftvector)
      DEALLOCATE(I_epsR_array)
      DEALLOCATE(I_epsA_array)
      DEALLOCATE(ekq)
      DEALLOCATE(matngmatmgpD)
      DEALLOCATE(achDtemp_corb)
      DEALLOCATE(ach2Dtemp)
      DEALLOCATE(schDi)
      DEALLOCATE(schDi_cor)
      DEALLOCATE(schDi_corb)
      DEALLOCATE(sch2Di)
      DEALLOCATE(wxi)
      DEALLOCATE(dFreqBrd)
      DEALLOCATE(dFreqGrid)

      write(6,*) "Runtime:", endtime-starttime
      write(6,*) "Runtime A:", time_a
      write(6,*) "Runtime B:", time_b
      write(6,*) "Runtime C:", time_c
      write(6,*) "Answer:", achDtemp_cor(1), achDtemp(1)

      DEALLOCATE(achDtemp)
      DEALLOCATE(achDtemp_cor)

end program

subroutine timget(wall)
  real(kind(1.0d0)) :: wall

  integer :: values(8)

  call date_and_time(VALUES=values)
  wall=((values(3)*24.0d0+values(5))*60.0d0 &
    +values(6))*60.0d0+values(7)+values(8)*1.0d-3

  return
end subroutine timget
