using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090ItDeclarationLockSetting
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public string? FinancialYear { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public decimal? EmpEnableDays { get; set; }
}
