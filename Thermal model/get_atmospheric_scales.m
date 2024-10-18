function [wstar, theta_star, qstar] = get_atmospheric_scales(p_surface,T_surface,RH_surface,p_sat_surface,Q_surface_tilda,zi,theta_bar_v)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Inputs:   T_surface   	    = Measured temperature at surface, K
    %           Q_surface_tilda     = Measured net radiation at surface, W/m^2
    %           RH_surface          = Measured relative humidity at surface, %
    %           p_surface           = Measured pressure at surface, Pa
    %           zi                  = Depth of the mixed layer, m
    %           theta_bar_v         = Daily average surface potential temperature, K (Allen's paper)
    %
    % Outputs:  wstar               = Mixed layer convective velocity scale, m/s
    %           theta_star          = Mixed layer temperature scale, K
    %           qstar               = Mixed layer humidity scale, kg_water/kg_air
    %
    % Variables:beta                = Bowen ratio, no unit, see Stull pg. 274
    %           rho                 = Density of moist air, kg/m^3
    %           cp                  = Specific heat of dry air, J/kg*K
    %           X                   = proportion of net radiation absorbed into the ground, (Stull section 7.6.1)
    %           Lv                  = latent heat of vaporization of water, J/kg_water 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Variables

    beta = 0.5;
    X = 0.1;
    rho = 1.210;
    cp = 1004.67;
    Lv = 2.45*10^6; % value for a boundary layer temperature of 20°C (Stull)
    g = 9.80665;    % standad gravity at surface, m/s^2 (IFM lecture notes)

    % CALCULATE BOUNDARY LAYER PARAMETERS (from Stull)
                                            
    % Heat budjet at surface.
    % Fluxes based on Stull, sections 2.6.1, 7.5.1 and 7.6.1, caculated using
    % the simple parametrization for flux partitioning and the Bowen ratio
    % method
    
    Q_surface = Q_surface_tilda/(rho*cp);                       % kinematic net radiation at surface
    Q_H = beta/(1+beta) * abs(Q_surface)*(1-X);                 % sensible heat flux at surface (kinematic), K*m/s
    Q_E = 1/(1+beta) * abs(Q_surface)*(1-X);                    % latent heat flux at surface (kinematic), K*m/s
    R = Q_E*cp/Lv;                                              % moisture flux at surface (kinematic), kg_water/kg_air * m/s
    
    % Surface virtual potential flux
    r_sat = 0.622*p_sat_surface/(p_surface-p_sat_surface);        % saturation mixing ratio
    r = RH_surface*r_sat/100;                                     % actual mixing ratio
    Q_ov = Q_H*(1+0.61*r);                                      % surface virtual potential temperature flux
    
    % CALCULATE OUTPUTS
    
    % mixed layer velocity, temperature and humidity scales (from Stull section 4.2)
    wstar = (Q_ov*zi*g/theta_bar_v)^1/3;                        % convective velocity scale, m/s
    theta_star = Q_H/wstar;                                     % temperature scale, K
    qstar = R/wstar;                                            % humidity scale, kg_water/kg_air
       
end


    
    