using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0065EmpLaunguageDetailGet
{
    public int RowId { get; set; }

    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public int CmpId { get; set; }

    public int LangId { get; set; }

    public string LangFluency { get; set; } = null!;

    public string? LangAbility { get; set; }

    public string LangName { get; set; } = null!;
}
