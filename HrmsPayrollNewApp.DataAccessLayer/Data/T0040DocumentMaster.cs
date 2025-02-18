using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040DocumentMaster
{
    public decimal DocId { get; set; }

    public decimal CmpId { get; set; }

    public string DocName { get; set; } = null!;

    public string DocComments { get; set; } = null!;

    public byte DocRequired { get; set; }

    public decimal DocumentTypeId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0055JobDocument> T0055JobDocuments { get; set; } = new List<T0055JobDocument>();

    public virtual ICollection<T0090EmpDocDetail> T0090EmpDocDetails { get; set; } = new List<T0090EmpDocDetail>();

    public virtual ICollection<T0090HrmsResumeDocument> T0090HrmsResumeDocuments { get; set; } = new List<T0090HrmsResumeDocument>();
}
