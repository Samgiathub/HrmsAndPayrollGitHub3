using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040LanguageMaster
{
    public decimal LangId { get; set; }

    public decimal CmpId { get; set; }

    public string LangName { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0090EmpLanguageDetail> T0090EmpLanguageDetails { get; set; } = new List<T0090EmpLanguageDetail>();
}
