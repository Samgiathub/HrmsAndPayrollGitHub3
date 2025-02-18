using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115RecruitmentResponsibiltyLevel
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal RecAppId { get; set; }

    public string Responsibility { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
