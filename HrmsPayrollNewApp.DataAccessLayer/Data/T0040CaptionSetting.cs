using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040CaptionSetting
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public string? Caption { get; set; }

    public string? Alias { get; set; }

    public decimal SortingNo { get; set; }

    public string? Remarks { get; set; }

    public string? ModuleName { get; set; }

    public string? GroupBy { get; set; }

    public string? CaptionCode { get; set; }

    public decimal IsHidden { get; set; }
}
