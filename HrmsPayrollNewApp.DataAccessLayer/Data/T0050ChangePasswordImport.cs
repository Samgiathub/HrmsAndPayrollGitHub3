using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050ChangePasswordImport
{
    public decimal SrNo { get; set; }

    public string? EmpCode { get; set; }

    public decimal? CmpId { get; set; }

    public string? Password { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? ChangeDate { get; set; }

    public string? IpAddress { get; set; }
}
