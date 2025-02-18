using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class UserInformation
{
    public int UserId { get; set; }

    public string? Ipaddress { get; set; }

    public string? Country { get; set; }

    public string? Region { get; set; }

    public string? City { get; set; }

    public string? ConnectionType { get; set; }

    public string? Browser { get; set; }

    public string? OperatingSystem { get; set; }

    public string? DeviceType { get; set; }

    public string? WeatherInfo { get; set; }

    public string? Timezone { get; set; }

    public string? Language { get; set; }

    public DateTime? CreatedDate { get; set; }
}
