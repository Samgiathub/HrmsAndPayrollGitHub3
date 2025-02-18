using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0250ReportFormatSetting
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public string? ModuleName { get; set; }

    public decimal PaperValue { get; set; }

    public decimal FormatValue { get; set; }

    public decimal SortingNo { get; set; }

    public string? FormatName { get; set; }
}
