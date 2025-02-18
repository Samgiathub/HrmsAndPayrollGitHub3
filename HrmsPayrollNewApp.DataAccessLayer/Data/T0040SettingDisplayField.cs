using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040SettingDisplayField
{
    public int TranId { get; set; }

    public decimal? CmpId { get; set; }

    public string? ModuleName { get; set; }

    public string? FieldName { get; set; }

    public string? ControlType { get; set; }

    public string? ControlDisplayName { get; set; }

    public bool? IsDisplay { get; set; }

    public int? SortingNo { get; set; }

    public int? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public string? IpAddress { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }
}
