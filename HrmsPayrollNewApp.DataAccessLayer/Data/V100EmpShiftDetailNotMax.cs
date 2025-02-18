using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V100EmpShiftDetailNotMax
{
    public decimal EmpId { get; set; }

    public decimal ShiftId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal CmpId { get; set; }

    public decimal ShiftTranId { get; set; }
}
