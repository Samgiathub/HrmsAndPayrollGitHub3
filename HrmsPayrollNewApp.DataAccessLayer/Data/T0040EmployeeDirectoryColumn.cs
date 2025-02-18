using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040EmployeeDirectoryColumn
{
    public int FieldId { get; set; }

    public decimal CmpId { get; set; }

    public string FieldName { get; set; } = null!;

    public string FieldLabel { get; set; } = null!;

    public string DataType { get; set; } = null!;

    public bool IsShow { get; set; }

    public int SortIndex { get; set; }

    public string Dbfield { get; set; } = null!;
}
