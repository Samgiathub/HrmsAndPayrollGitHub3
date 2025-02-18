using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpShiftDetail
{
    public decimal ShiftTranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ShiftId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? ShiftType { get; set; }

    public decimal? RotationId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040ShiftMaster Shift { get; set; } = null!;
}
