using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050EmpMonthlyShiftRotation
{
    public decimal CmpId { get; set; }

    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal RotationId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public DateTime SysDate { get; set; }
}
