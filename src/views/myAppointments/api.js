
export function addAppointmentService(department, doctor, username, day) {
    return request.get('/register/addApp', {
        params: {  
            department,
            doctor, 
            username,
            day
        }
    });
}

export function deleteAppointmentService(department, doctor, username, day) {
    return request.get('/register/cancelApp', {
        params: {  
            department,
            doctor, 
            username,
            day
        }
    });
}

export function registerGetMyService(username){
    return request.get('/register/getMy', {
        params: {
            username
        }
    })
}

export function registerGetHealthRecordsService(){
    return request.get('/register/getHealthRecords')
}