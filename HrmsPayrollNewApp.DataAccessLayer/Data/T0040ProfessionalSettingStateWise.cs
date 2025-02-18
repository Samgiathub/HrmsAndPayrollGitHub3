using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040ProfessionalSettingStateWise
{
    public decimal CmpId { get; set; }

    public decimal? StateId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal RowId { get; set; }

    public decimal FromLimit { get; set; }

    public decimal ToLimit { get; set; }

    public decimal Amount { get; set; }
}
