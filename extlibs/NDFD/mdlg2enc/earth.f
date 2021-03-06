      SUBROUTINE EARTH(KFILDO,IPACK,ND5,IS3,NS3,L3264B,
     1                 LOCN,IPOS,IER)
C
C        MARCH    2000   LAWRENCE  GSC/TDL   ORIGINAL CODING
C        JANUARY  2001   GLAHN     COMMENTS; CHANGED IER = 24 TO 310
C        JANUARY  2001   GLAHN/LAWRENCE FILLED SOME ELEMENTS OF IS3( );
C                                  CORRECTED IS3(13).EQ.2 ERROR TO
C                                  IS3(15).EQ.2; CORRECTED IS2(23)
C                                  ERROR TO IS3(22) IN CALL TO PKBG
C        FEBRUARY 2001   GLAHN/LAWRENCE CHANGED IS3(16)=IRADIUS TO
C                                  IS3(17); AND IS3(22)=IMINAXIS TO
C                                  IS3(27); REMOVED RETURN 1
C
C        PURPOSE
C            PACKS SHAPE OF THE EARTH INFORMATION INTO SECTION 3
C            OF A GRIB2 MESSAGE.  THIS INFORMATION IS BASED
C            ON TABLE 3.2 OF THE WMO GRIB2 DOCUMENTATION AND IS
C            REQUIRED BY MANY OF THE MAP TEMPLATES IN SECTION 3.
C
C            THE USER HAS THE OPTION TO CHOOSE A SPHERICAL EARTH
C            OR AN OBLATE SPHEROID EARTH. FOR THE SPHERICAL EARTH
C            THE USER MAY EITHER USE THE EARTH'S RADIUS AS DEFINED
C            BY THE WMO OR SUPPLY HIS/HER OWN RADIUS VALUE. FOR THE
C            OBLATE SPHEROID EARTH, THE USER MAY EITHER USE THE
C            MAJOR AND MINOR AXES LENGTHS AS DEFINED BY THE WMO OR
C            SUPPLY HIS/HER OWN VALUES FOR THEM.
C
C        DATA SET USE
C           KFILDO - UNIT NUMBER FOR OUTPUT (PRINT) FILE. (OUTPUT)
C
C        VARIABLES
C              KFILDO = UNIT NUMBER FOR OUTPUT (PRINT) FILE. (INPUT)
C            IPACK(J) = THE ARRAY THAT HOLDS THE ACTUAL PACKED MESSAGE
C                       (J=1,ND5). (INPUT/OUTPUT)
C                 ND5 = THE SIZE OF THE ARRAY IPACK( ). (INPUT)
C              IS3(J) = CONTAINS THE EARTH-SHAPE INFORMATION
C                       (IN ELEMENTS 15 THROUGH 27) THAT WILL BE
C                       PACKED INTO IPACK( ) (J=1,NS3). (INPUT)
C                 NS3 = SIZE OF IS3( ). (INPUT/OUTPUT) 
C              L3264B = THE INTEGER WORD LENGTH IN BITS OF THE MACHINE
C                       BEING USED. VALUES OF 32 AND 64 ARE
C                       ACCOMMODATED. (INPUT)
C                LOCN = THE WORD POSITION TO PLACE THE NEXT VALUE.
C                       (INPUT/OUTPUT)
C                IPOS = THE BIT POSITION IN LOCN TO START PLACING
C                       THE NEXT VALUE. (INPUT/OUTPUT)
C                 IER = RETURN STATUS CODE. (OUTPUT)
C                         0 = GOOD RETURN.
C                       1-4 = ERROR CODES GENERATED BY PKBG. SEE THE 
C                             DOCUMENTATION IN THE PKBG ROUTINE.
C                       310 = UNSUPPORTED SHAPE OF EARTH CODE IN
C                             IS3(15).
C
C             LOCAL VARIABLES
C            EARTHRAD = THE EARTH'S RADIUS AS OUTLINED IN THE
C                       WMO GRIB2 DOCUMENTATION, CODE TABLE 3.2.
C                       THIS IS IN KM ANDAPPLIES TO A SPHERICAL EARTH.
C            EMAJAXIS = THE MAJOR AXIS OF AN OBLATE SPHEROID EARTH
C                       AS OUTLINED IN THE WMO GRIB2 DOCUMENTATION,
C                       CODE TABLE 3.2.  THE VALUE IS IN KM.
C            EMINAXIS = THE MINOR AXIS OF AN OBLATE SPHEROID EARTH
C                       AS OUTLINED IN THE WMO GRIB2 DOCUMENTATION,
C                       CODE TABLE 3.2.  THE VALUE IS IN KM.
C            IMAJAXIS = THE SCALED MAJOR AXIS OF AN OBLATE SPHEROID
C                       EARTH.
C            IMINAXIS = THE SCALED MINOR AXIS OF AN OBLATE SPHEROID
C                       EARTH.
C             IRADIUS = THE SCALED RADIUS OF A SPHERICAL EARTH
C            ISCALEMJ = THE DECIMAL SCALE FACTOR TO MULTIPLY THE
C                       MAJOR AXIS OF THE EARTH (EMAJAXIS) BY TO
C                       RETAIN ITS PRECISION WHEN THE VALUE IS PACKED.
C            ISCALEMN = THE DECIMAL SCALE FACTOR TO MULTIPLY THE
C                       MINOR AXIS OF THE EARTH (EMINAXIS) BY TO
C                       RETAIN ITS PRECISION WHEN THE VALUE IS PACKED.
C            ISCALERD = THE DECIMAL SCALE FACTOR TO MULTIPLY THE
C                       RADIUS OF THE EARTH (EARTHRAD) BY TO
C                       RETAIN ITS PRECISION WHEN THE VALUE IS PACKED.
C                   N = L3264B = THE INTEGER WORD LENGTH IN BITS OF
C                       THE MACHINE BEING USED. VALUES OF 32 AND
C                       64 ARE ACCOMMODATED.
C
C        NON SYSTEM SUBROUTINES CALLED
C           PKBG
C
      PARAMETER (EARTHRAD=6367.47,
     1           ISCALERD=2,
     2           EMAJAXIS=6378.160,
     3           ISCALEMJ=3,
     4           EMINAXIS=6356.775,
     5           ISCALEMN=3)
C
      DIMENSION IPACK(ND5),IS3(NS3)
C
      DATA IZERO/0/
C
      N=L3264B
      IER=0
C
C        PACK THE SHAPE OF THE EARTH.
      CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(15),8,N,IER,*900)
C
C        DEPENDING ON THE SHAPE OF THE EARTH THAT THE
C        USER HAS CHOSEN, PACK THE APPROPRIATE SCALE
C        FACTOR AND VALUE FOR THE RADIUS OF THE EARTH.
      IF((IS3(15).EQ.0).OR.(IS3(15).EQ.1))THEN
C
         IF(IS3(15).EQ.0)THEN
C              PACK THE SCALE FACTOR OF THE RADIUS OF THE
C              SPHERICAL EARTH AND THE SCALED RADIUS OF THE
C              SPHERICAL EARTH AS DEFINED IN THE WMO GRIB2
C              DOCUMENTATION, IN THIS CASE 2.
            IRADIUS=NINT((10**ISCALERD)*EARTHRAD)
            CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,ISCALERD,8,N,
     1                IER,*900)
            IS3(16)=ISCALERD
            CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IRADIUS,
     1                32,N,IER,*900)
            IS3(17)=IRADIUS
         ELSE
C
C              PACK THE SCALE FACTOR OF THE RADIUS OF THE
C              SPHERICAL EARTH AND THE SCALED RADIUS OF THE
C              SPHERICAL EARTH AS DEFINED BY THE USER IN THE
C              IS3( ) ARRAY.
            CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(16),8,N,
     1                IER,*900)
            CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(17),32,N,
     1                IER,*900)
         ENDIF
C
C           ZERO OUT THE LOCATIONS PERTAINING TO AN OBLATE
C           SPHERIOD EARTH.
C
         CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IZERO,32,N,IER,*900)
         CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IZERO,32,N,IER,*900)
         CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IZERO,16,N,IER,*900)
C
      ELSEIF((IS3(15).EQ.2).OR.(IS3(15).EQ.3))THEN
C
C           ZERO OUT THE LOCATIONS PERTAINING TO A SPHERICAL
C           EARTH.
C
         CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IZERO,32,N,IER,*900)
         CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IZERO,8,N,IER,*900)
C
         IF(IS3(15).EQ.2)THEN
C
C              PACK THE SCALE FACTOR OF THE MAJOR AND MINOR
C              AXES OF AN OBLATE SPHEROID EARTH ALONG WITH
C              WITH THEIR SCALED VALUES AS DEFINED BY THE
C              WMO GRIB2 DOCUMENTATION.
            IMAJAXIS=NINT((10**ISCALEMJ)*EMAJAXIS)
            CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,ISCALEMJ,8,N,
     1                IER,*900)
            IS3(21)=ISCALEMJ
            CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IMAJAXIS,
     1                32,N,IER,*900)
            IS3(22)=IMAJAXIS
            IMINAXIS=NINT((10**ISCALEMN)*EMINAXIS)
            CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,ISCALEMN,8,N,
     1                IER,*900)
            IS3(26)=ISCALEMN
            CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IMINAXIS,
     1                32,N,IER,*900)
            IS3(27)=IMINAXIS
         ELSE
C
C              PACK THE SCALE FACTOR OF THE MAJOR AND MINOR
C              AXES OF AN OBLATE SPHEROID EARTH ALONG WITH
C              WITH THEIR SCALED VALUES AS DEFINED BY THE
C              USER.
            CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(21),8,N,
     1                IER,*900)
            CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(22),
     1                32,N,IER,*900)
            CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(26),8,N,
     1                IER,*900)
            CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(27),
     1                32,N,IER,*900)
         ENDIF
C
      ELSE
C           AN INVALID OR UNSUPPORTED CODE FOR THE SHAPE OF THE
C           EARTH IS IN IS3(15).
         IER=310
      ENDIF
C
 900  RETURN
      END
