using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100LoginDetailHistory
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LoginId { get; set; }

    public string? UserName { get; set; }

    public string? Password { get; set; }

    public DateTime SystemDate { get; set; }

    public byte Status { get; set; }

    public string? IpAddress { get; set; }
}
