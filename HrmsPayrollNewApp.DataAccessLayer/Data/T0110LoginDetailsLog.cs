using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110LoginDetailsLog
{
    public decimal Id { get; set; }

    public decimal CmpId { get; set; }

    public string UserId { get; set; } = null!;

    public string Ipaddress { get; set; } = null!;

    public DateTime Datetime { get; set; }

    public byte? IsLoggedIn { get; set; }

    public DateTime? LogoutDate { get; set; }
}
