using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0140TravelExpenseMasterBackup06012021
{
    public decimal ExpenseTypeId { get; set; }

    public string ExpenseTypeName { get; set; } = null!;

    public string ExpenseTypeGroup { get; set; } = null!;

    public byte GradeWiseExAmount { get; set; }

    public byte IsOverlimit { get; set; }

    public string GradeIdMulti { get; set; } = null!;

    public decimal CmpId { get; set; }
}
