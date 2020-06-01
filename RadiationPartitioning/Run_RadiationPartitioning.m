load ForcingData_ZH % Load data

% Meteorological input data
Date		=	datenum(MeteoDataZH_h.Time);			% Date and time
Tatm		=	MeteoDataZH_h.Tatm;						% Air temperature [K]
Pr			=	MeteoDataZH_h.Precipitation;			% precipitation [mm]
RH			=	MeteoDataZH_h.RelativeHumidity./100;	% Relative humidity
esat_Tatm	=	611.*exp(17.27.*(Tatm-273.15)./(237.3+(Tatm-273.15)));	% vapor pressure saturation at Tatm [Pa]
ea			=	esat_Tatm.*RH./1000;					% vapor pressure [kPa]
Tdew		=	(log(ea)+0.49299)./(0.0707-0.00421.*log(ea));	% dew point temperature in degrees celcius (book hydrometeorology chapter 2 p. 21)
Rsw			=	MeteoDataZH_h.SWRin;					% Add the total incoming shortwave radiation

% Location parameters
DeltaGMT	=	1;		% DeltaGMT = difference with Greenwich Meridian Time [h]
Lat			=	47.38;	% latitude north = positive(degrees)
Lon			=	8.56;	% longitude east = positive (degrees)
Zbas		=	556;	% Elevation of the station [m a.s.l]
GRAPH_VAR	=	1; % this just shows you the graph on some of the itterations


% These are the variables that you need as an input for the radiation partitioning. If you measured them
% directly, even better. I just put some equations on top that I use for my
% partitioning.
clearvars -except Date N Pr Tdew DeltaGMT Lat Lon Zbas Rsw GRAPH_VAR MeteoDataZH_h Tatm ea

%% Shortwave radiation partitioning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform the radiation partitioning
[SD,SB,SAD1,SAD2,SAB1,SAB2,PARB,PARD,N,Rsws,t_bef,t_aft]=Automatic_Radiation_Partition(Date,Lat,Lon,Zbas,DeltaGMT,Pr,Tdew,Rsw,GRAPH_VAR);


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
plot(MeteoDataZH_h.Time,Test,'DisplayName','SWRin-SAB1-SAD1-SAB2-SAD2')
xlim([MeteoDataZH_h.Time(1) MeteoDataZH_h.Time(end)])
legend('show')
title('Measured SWRin - simulated SWRin')

figure
plot(MeteoDataZH_h.Time,MeteoDataZH_h.SWRin,'DisplayName','SWRin')
hold on
plot(MeteoDataZH_h.Time,SABtotal,'DisplayName','SAB total')
xlim([MeteoDataZH_h.Time(1) MeteoDataZH_h.Time(end)])
legend('show')
title('Direct SWRin of total SWRin')

figure
plot(MeteoDataZH_h.Time,MeteoDataZH_h.SWRin,'DisplayName','SWRin')
hold on
plot(MeteoDataZH_h.Time,SADtotal,'DisplayName','SAD total')
xlim([MeteoDataZH_h.Time(1) MeteoDataZH_h.Time(end)])
legend('show')
title('Diffuse SWRin of total SWRin')

figure
plot(MeteoDataZH_h.Time,SWRintotal,'DisplayName','SWR total radiation partitioning')
hold on
plot(MeteoDataZH_h.Time,MeteoDataZH_h.SWRin,'DisplayName','SWRin measured')
xlim([MeteoDataZH_h.Time(1) MeteoDataZH_h.Time(end)])
legend('show')
title('Measured SWRin and simulated SWRin')


% Solve Partitioned Radiation
MeteoDataZH_h.SAB1	=	SAB1';
MeteoDataZH_h.SAB2	=	SAB2';
MeteoDataZH_h.SAD1	=	SAD1';
MeteoDataZH_h.SAD2	=	SAD2';

save('MeteoDataZH_h_SWR_RadPart','MeteoDataZH_h')
