###############################################################################
# FUNCTIONS to (re)calculate sap flow metrics
# They are similar to that in the SFA but with the necessary modifications
# to use them outside the SFA
###############################################################################




get.sapFlowDensity <- function(data, sf_formula = "Positive"){
    data$SFSpos = 3600 * data$Dst * (data[, "k"] + data[, "dTsa"]) / data[, "dTas"] *
        data$Zax / data$Ztg
    # Eq. 1 in NNadezhdina & Nadezhdin, 2017
    if (sf_formula == "Positive"){
        data$SFS = data$SFSpos
    }
    # Eq. 2 in Nadezhdina & Nadezhdin, 2017
    if (sf_formula == "Negative"){
        data = get.negativeSFS(data)
    }

    data$SFDsw = data$SFS / data$swd
    return(data)
}



get.sapFlowDensitySA <- function(data, f_k, f_D, f_Z, f_swd){
    data$SFS = 3600 * (data$Dst*f_D) * ((data[, "k"]*f_k) + data[, "dTsa"]) / data[, "dTas"] *
        (data$Zax / data$Ztg*f_Z)
    data$SFDsw = data$SFS / (data$swd*f_swd)
    return(data)
}

get.negativeSFS = function(data){
    data = data %>%
        mutate(SFS = ifelse(dTSym >= neg_SFS_threshold, SFSpos,
                            -3600 * Dst * (-k + dTas) / dTsa * Zax / Ztg))
    return(data)
}

treeScaleSimple1 <- function(data) {
    # Calculate sap flow rate at each sensor depth
    if ("SFDsw" %in% colnames(data)){
        data$SFdepth = data$SFDsw * data$Aring
        # Calculate sap flow rate per time step over alls depths in kg/h
        data = data %>%
            group_by(id, datetime) %>%
            mutate(sfM1 = sum(SFdepth, na.rm = T) / 1000) %>%
            ungroup()
    } else {
        data$SFdepth = 0
        data$SFDsw = 0
        data$sfM1 = 0
    }
    return(data)
}

get.rxy = function(stemDiameter, barkThickness){
    rxy = stemDiameter / 2 - barkThickness
    
    return(rxy)
}

get.r1 = function(rxy, spacer, barkThickness){
    if (rxy != 0){
        r1 = rxy - (20/10 - spacer/10 - barkThickness)
    }
    else {
        r1 = 0
    }
    return(r1)
}


get.ringSize = function(data){
    # Calculate area and circumference of annuli
    data = data %>% 
        mutate(r_outer = depth + 0.5,
               r_inner = depth - 0.5,
               Aring = pi*(r_outer^2 - r_inner^2),
               R = depth,
               Cring = 2*pi * R) %>% 
        mutate(Aring = abs(Aring),
               Cring = abs(Cring))
    return(data)
}

get.SWArea = function(data, stemDiameter, barkThickness, swd){
    rxy = get.rxy(stemDiameter, barkThickness)
    if (rxy != 0){
        A_rxy = pi * rxy^2
        A_hw = pi * (rxy - swd)^2
        data$SWDarea = A_rxy - A_hw
    } else {
        data$SWDarea = 0
    }
    return(data)
}

treeScaleSimple2 <- function(data, swd, ui.input) {
    depths = unique(data$depth)
    
    # Calculate mean sap flow per section and divide it by sap wood depth
    if ("SFDsw" %in% colnames(data)){
        data = data %>%
            group_by(id, datetime) %>%
            mutate(SFD_mean = mean(SFDsw, na.rm = T)) %>% 
            ungroup()
        
        # Calculate sap flow rate per time step over alls depths in kg/h
        data$sfM2 = data$SFD_mean * data$SWDarea / 1000
    } else {
        data$SFD_mean = 0
        data$sfM2 = 0
    }
    return(data)
}


treeScaleSimple3 <- function(data) {
    data$SFdepthm3 = data$SFS * data$Cring
    if ("dataset" %in% colnames(data)){
        data = data %>%
            group_by(dataset, id, datetime)
    } else {
        data = data %>%
            group_by(id, datetime)
    }
    data = data %>%
        mutate(sfM3 = mean(SFdepthm3, na.rm = T) / 1000) %>%
        ungroup()
    return(data)
}


get.treeWaterUseByMethod = function(data){
    data = data %>% 
        gather(., Method, SFrate, sfM1, sfM2, sfM3) %>% 
        mutate(Method = ifelse(Method == "sfM1", "Method 1",
                               ifelse(Method == "sfM2", "Method 2",
                                      "Method 3")),
               Balance = ifelse(SFrate >= 0, "Positive", "Negative")) %>% 
        mutate(Balance = factor(Balance, levels = c("Positive", "Negative"))) %>%
        filter(complete.cases(SFrate))

    data = data %>% 
        select(id, datetime, doy, dTime, Method, SFrate, Balance) %>% 
        unique(.) %>% 
        group_by(id, doy, Method, Balance) %>% 
        arrange(dTime) %>% 
        mutate(roll_mean = (SFrate + lag(SFrate))/2,
               delta_x = dTime - lag(dTime),
               trapezoid = delta_x * roll_mean) %>% 
        mutate(auc = sum(trapezoid, na.rm = T)) %>%
        select(id, doy, Method, Balance, auc) %>% 
        unique(.) %>% 
        rename('TWU' = 'auc') %>%   ungroup() %>% 
        spread(., Balance, 'TWU') %>% 
        mutate_if(is.numeric, round, 2)
    
    return(data)
}

get.treeWaterUseMethod3 = function(data){
    data = data %>% 
        mutate(Balance = ifelse(sfM3 >= 0, "Positive", "Negative")) %>% 
        mutate(Balance = factor(Balance, levels = c("Positive", "Negative"))) %>%
        filter(complete.cases(sfM3))
    
    data = data %>% 
        select(dataset, id, datetime, doy, dTime, sfM3, Balance) %>% 
        unique(.) %>% 
        group_by(dataset, id, doy, Balance) %>% 
        arrange(dTime) %>% 
        mutate(roll_mean = (sfM3 + lag(sfM3))/2,
               delta_x = dTime - lag(dTime),
               trapezoid = delta_x * roll_mean) %>% 
        mutate(auc = sum(trapezoid, na.rm = T)) %>%
        select(dataset, id, doy, Balance, auc) %>% 
        unique(.) %>% 
        rename('TWU' = 'auc') %>%   ungroup() %>% 
        spread(., Balance, 'TWU') %>% 
        mutate_if(is.numeric, round, 2)
    
    return(data)
}

