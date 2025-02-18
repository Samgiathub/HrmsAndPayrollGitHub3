using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0082EmpColumn
{
    public decimal TranId { get; set; }

    public decimal MstTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string? Value { get; set; }

    public DateTime? SysDate { get; set; }

    public virtual T0081CustomizedColumn MstTran { get; set; } = null!;
}
