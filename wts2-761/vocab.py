#
#
# merge single vocabulary tables into voc_vocab/voc_term
#
 
import sys 
import os
import db

db.setTrace()

vocabs = { 
        '151': ('GXD_AntibodyClass', '_antibodyclass_key', 'class', ['GXD_Antibody']),
        '152': ('GXD_Label', '_label_key', 'label', ['GXD_AntibodyPrep', 'GXD_ProbePrep']),
        '153': ('GXD_Pattern', '_pattern_key', 'pattern', ['GXD_InSituResult']),
        '154': ('GXD_GelControl', '_gelcontrol_key', 'gelLaneContent', ['GXD_GelLane']),
        '155': ('GXD_EmbeddingMethod', '_embedding_key', 'embeddingMethod', ['GXD_Specimen']),
        '156': ('GXD_FixationMethod', '_Fixation_key', 'fixation', ['GXD_Specimen']),
        '157': ('GXD_VisualizationMethod', '_Visualization_key', 'visualization', ['GXD_ProbePrep']),
        '159': ('GXD_ProbeSense', '_sense_key', 'sense', ['GXD_ProbePrep']),
        '160': ('GXD_Secondary', '_secondary_key', 'secondary', ['GXD_AntibodyPrep']),
        '163': ('GXD_Strength', '_strength_key', 'strength', ['GXD_GelBand', 'GXD_InSituResult']),
        '172': ('GXD_GelRNAType', '_gelrnatype_key', 'rnatype', ['GXD_GelLane']),
        '173': ('GXD_GelUnits', '_gelunits_key', 'units', ['GXD_GelRow']),
        '175': ('GXD_AntibodyType', '_antibodytype_key', 'antibodytype', ['GXD_Antibody'])
        }

#
# Main
#

db.useOneConnection(1)

for vkey in vocabs:

        v = vocabs[vkey]

        vtable = v[0]
        termkey = v[1]
        termclass = v[2]
        xtables = v[3]
        print(vkey, vtable, termkey, termclass, xtables)

        # delete any existing vocab terms for this vkey; reload
        db.sql('delete from voc_term where _vocab_key = %s' % (vkey), None)

        # existing terms in old vocabulary table (vtable)
        seqnum = 1
        results = db.sql(''' select %s, %s from %s ''' % (termkey, termclass, vtable), 'auto')
        for r in results:
                # add existing vtable/term to voc_term using new vocabulary(vkey)
                print(r)
                oldtermname = r['%s'% (termclass)]
                db.sql('''insert into VOC_Term values(nextval('voc_term_seq'),%s,'%s',null,null,%s,0,1001,1001,now(),now())''' % (vkey, oldtermname, seqnum), None)
                db.commit()
                seqnum += 1

        # find new vocab/key which matches old vocab/key
        # update old term key = new term key

        for xtable in xtables:

                sql = '''
                select distinct t._term_key, t.term, o.%s, o.%s
                from voc_term t, %s o, %s x
                where t._vocab_key = %s
                and t.term = o.%s
                and o.%s = x.%s
                ''' % (termkey, termclass, vtable, xtable, vkey, termclass, termkey, termkey)
                xresults = db.sql(sql, 'auto')
                for x in xresults:
                        print(x)
                        oldtermkey = x['%s' % (termkey)]
                        sql = ''' update %s set %s = %s where %s = %s ''' % (xtable, termkey, x['_term_key'], termkey, oldtermkey)
                        #print(sql)
                        db.sql(sql, None)
                        db.commit()

db.useOneConnection(0)

