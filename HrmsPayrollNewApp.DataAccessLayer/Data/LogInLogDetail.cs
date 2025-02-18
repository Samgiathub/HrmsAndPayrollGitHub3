using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class LogInLogDetail
{
    public int Id { get; set; }

    public int? CmpId { get; set; }

    public string? UserId { get; set; }

    public string? Ipaddress { get; set; }

    public DateTime? LogInDateTime { get; set; }

    public DateTime? LogOutDateTime { get; set; }

    public bool? Islogged { get; set; }
}
