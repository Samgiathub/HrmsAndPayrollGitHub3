using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100RejoinEmp
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime LeftDate { get; set; }

    public DateTime RejoinDate { get; set; }

    public string Remarks { get; set; } = null!;

    public DateTime SystemDate { get; set; }
}
