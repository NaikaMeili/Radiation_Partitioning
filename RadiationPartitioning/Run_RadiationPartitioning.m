load ForcingData_ZH2010 % Load data

% Meteorological input data (required)
Date		=	datenum(MeteoDataZH_h.Time);			% Date and time
Tatm		=	MeteoDataZH_h.Tatm;						% Air temperature [K]
Pr			=	MeteoDataZH_h.Precipitation;			% precipitation [mm]
RH			=	MeteoDataZH_h.RelativeHumidity./100;	% Relative humidity [-]
Rsw			=	MeteoDataZH_h.SWRin;					% Add the total incoming shortwave radiation [W/m2]

% Calculated internally
esat_Tatm	=	611.*exp(17.27.*(Tatm-273.15)./(237.3+(Tatm-273.15)));	% vapor pressure saturation at Tatm [Pa]
ea			=	esat_Tatm.*RH./1000;					% vapor pressure [kPa]
Tdew		=	(log(ea)+0.49299)./(0.0707-0.00421.*log(ea));	% dew point temperature in degrees celcius (book hydrometeorology chapter 2 p. 21)

% Location parameters (required)
DeltaGMT	=	1;		% DeltaGMT = difference with Greenwich Meridian Time [h]
Lat			=	47.38;	% latitude north = positive(degrees)
Lon			=	8.56;	% longitude east = positive (degrees)
Zbas		=	556;	% Elevation of the station [m a.s.l]
GRAPH_VAR	=	0;      % shows you the graph on some of the itterations (1), do not show graphs (0)

CalculateLWR = 1; % To calculate longwave radiation put 1, otherwise 0

% Clear unused variables
clearvars -except Date N Pr Tdew DeltaGMT Lat Lon Zbas Rsw GRAPH_VAR MeteoDataZH_h Tatm ea CalculateLWR

%% Shortwave radiation partitioning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform the radiation partitioning
[SD,SB,SAD1,SAD2,SAB1,SAB2,PARB,PARD,N,Rsws,t_bef,t_aft]=Automatic_Radiation_Partition(Date,Lat,Lon,Zbas,DeltaGMT,Pr,Tdew,Rsw,GRAPH_VAR);

if CalculateLWR==1
[Latm]=Incoming_Longwave(Tatm-273.15,ea.*1000,N);
end

% Output:
% SAD1: Diffuse radiation band 1
% SAD2: Diffuse radiation band 2
% SAB1: Direct beam radiation band 1
% SAB2: Direct beam radiation band 2
% N	: Cloudiness
% Rsws:	 Total shortwave radiation
Test	=	MeteoDataZH_h.SWRin-SAB1'-SAB2'-SAD1'-SAD2';

SABtotal	=	SAB1'+SAB2';
SADtotal	=	SAD1'+SAD2';
SWRintotal	=	SAB1'+SAB2'+SAD1'+SAD2';

figure
subplot(2,1,1)
plot(MeteoDataZH_h.Time,Test,'DisplayName','SWRin-SAB1-SAD1-SAB2-SAD2')
xlim([MeteoDataZH_h.Time(1) MeteoDataZH_h.Time(end)])
legend('show'); ylabel('[W/m^2]');
title('Measured SWRin - simulated SWRin')

% Sometimes in the early morning or evening hours, shortwave radiation is 
% measured (SWRin) but the code assumes no shortwave radiation during that
% time leading to a small non-closure of the original SWRin and the radiation
% partitioned SWRin. In these cases, the excess radiation is added to the 
% diffuse radiation as done below
SWRnonclosure = abs(Test)>10^-6;

SAD1(SWRnonclosure) = SAD1(SWRnonclosure) + Test(SWRnonclosure)'./2;
SAD2(SWRnonclosure) = SAD2(SWRnonclosure) + Test(SWRnonclosure)'./2;

Test	=	MeteoDataZH_h.SWRin-SAB1'-SAB2'-SAD1'-SAD2';

SABtotal	=	SAB1'+SAB2';
SADtotal	=	SAD1'+SAD2';
SWRintotal	=	SAB1'+SAB2'+SAD1'+SAD2';

subplot(2,1,2)
plot(MeteoDataZH_h.Time,Test,'DisplayName','SWRin-SAB1-SAD1-SAB2-SAD2')
xlim([MeteoDataZH_h.Time(1) MeteoDataZH_h.Time(end)])
legend('show'); ylabel('[W/m^2]');
title('Measured SWRin - simulated SWRin')

%-------------------------------
figure
subplot(2,1,1)
plot(MeteoDataZH_h.Time,MeteoDataZH_h.SWRin,'DisplayName','SWRin')
hold on
plot(MeteoDataZH_h.Time,SABtotal,'DisplayName','SAB total')
xlim([MeteoDataZH_h.Time(1) MeteoDataZH_h.Time(end)])
legend('show'); ylabel('[W/m^2]');
title('Direct SWRin of total SWRin')

subplot(2,1,2)
plot(MeteoDataZH_h.Time,MeteoDataZH_h.SWRin,'DisplayName','SWRin')
hold on
plot(MeteoDataZH_h.Time,SADtotal,'DisplayName','SAD total')
xlim([MeteoDataZH_h.Time(1) MeteoDataZH_h.Time(end)])
legend('show'); ylabel('[W/m^2]');
title('Diffuse SWRin of total SWRin')



% Solve Partitioned Radiation
MeteoDataZH_h.SAB1	=	SAB1';
MeteoDataZH_h.SAB2	=	SAB2';
MeteoDataZH_h.SAD1	=	SAD1';
MeteoDataZH_h.SAD2	=	SAD2';
if CalculateLWR==1
MeteoDataZH_h.LWRin =   Latm;
end

save('MeteoData_ZH2010_RadPart','MeteoDataZH_h')
