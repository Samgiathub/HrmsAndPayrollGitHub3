using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SingleDeviceLogin
{
    public int Id { get; set; }

    public decimal? LoginId { get; set; }

    public decimal? CmpId { get; set; }

    public string? ImeiNo { get; set; }

    public bool? IsLoggedIn { get; set; }
}
