###############################################################################
# HELPER FUNCTIONS to read and concatenate raw data into data frames
# Input data: csv files from the SFA submitted by trial participants
# NOTE: For this file to work, unzip folders in data/raw/
###############################################################################


path_to_raw = "data/raw"

get.files = function(dataset) {
    f = list.files(paste(path_to_raw, dataset, sep = "/")) %>%
        str_subset(pattern = ".csv")
    
    return(
        data.frame(filename = f) %>% rowwise() %>%
            mutate(
                filename_2 = strsplit(filename, "[.]")[[1]][1],
                dataset = tolower(strsplit(filename_2, "_")[[1]][1]),
                user_ID = as.numeric(gsub(".*?([0-9]+).*", "\\1", filename_2)),
                file = strsplit(filename_2, "_")[[1]][3]
            )
    )
}


get_kfiles <- function(k_files, dataset) {
    k_data = data.frame()
    for (i in 1:nrow(k_files)){
        f = k_files[i, "filename"][[1]]
        d = fread(paste(path_to_raw, dataset, f, sep = "/")) 
        
        if (!"method"%in% colnames(d)){
            d$method = NA
            d = d %>% 
                select(position, method, k)
        }
        k_data = rbind(k_data, d %>% 
                           mutate(dataset = k_files[i, "dataset"][[1]],
                                  id = k_files[i, "user_ID"][[1]]))
    }
    return(k_data)
}



get_twufiles <- function(twu_files, dataset) {
    twu_data = data.frame()
    for (i in 1:nrow(twu_files)){
        f = twu_files[i, "filename"][[1]]
        d = fread(paste(path_to_raw, dataset, f, sep = "/")) 
        
        if (!"Negative"%in% colnames(d)){
            d$Negative = NA
        }
        
        twu_data = rbind(twu_data, d %>% 
                             mutate(dataset = twu_files[i, "dataset"][[1]],
                                    id = twu_files[i, "user_ID"][[1]]))
    }
    colnames(twu_data)[1] = "doy"
    
    return(twu_data)
}


get_sensorfiles <- function(sensor_files, dataset){
    sensor_data = data.frame()
    
    for (i in 1:nrow(sensor_files)){
        f = sensor_files[i, "filename"][[1]]
        d = fread(paste(path_to_raw, dataset, f, sep = "/")) 
        colnames(d) = c("position", "R", "A", "C")
        sensor_data = rbind(sensor_data, d %>% 
                                mutate(dataset = sensor_files[i, "dataset"][[1]],
                                       id = sensor_files[i, "user_ID"][[1]]))
    }
    return(sensor_data)
}


get_sapflowfiles <- function(sapflow_files, dataset) {
    for (i in 1:nrow(sapflow_files)) {
        f = sapflow_files[i, "filename"][[1]]
        d = fread(paste(path_to_raw, dataset, f, sep = "/"))
        if (!"neg_SFS_threshold" %in% colnames(d)) {
            d$neg_SFS_threshold = NA
        }
        d = d %>%
            mutate(dataset = sapflow_files[i, "dataset"][[1]],
                   id = sapflow_files[i, "user_ID"][[1]])
        if (i == 1) {
            sapflow_data = d
        } else {
            sapflow_data = sapflow_data %>%
                bind_rows(d)
        }
    }
    return(sapflow_data)
}