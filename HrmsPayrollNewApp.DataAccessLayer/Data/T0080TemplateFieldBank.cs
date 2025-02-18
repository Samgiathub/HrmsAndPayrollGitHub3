using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080TemplateFieldBank
{
    public int TfbId { get; set; }

    public int CmpId { get; set; }

    public string? FieldName { get; set; }

    public string? FieldType { get; set; }

    public string? Options { get; set; }
}
