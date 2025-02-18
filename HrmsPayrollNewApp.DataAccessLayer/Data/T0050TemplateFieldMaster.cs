using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050TemplateFieldMaster
{
    public int FId { get; set; }

    public int CmpId { get; set; }

    public int TId { get; set; }

    public string? FieldName { get; set; }

    public string? FieldType { get; set; }

    public string? Options { get; set; }

    public int? SortingNo { get; set; }

    public int? IsRequired { get; set; }

    public int? IsEnable { get; set; }

    public int? IsNumeric { get; set; }
}
